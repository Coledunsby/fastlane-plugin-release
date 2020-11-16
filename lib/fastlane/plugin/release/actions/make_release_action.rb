require 'fastlane/action'
require 'fastlane/plugin/remove_git_tag'
require_relative '../helper/make_release_helper'

module Fastlane

    module Actions

        class MakeReleaseAction < Action

            def self.run(params)

                other_action.ensure_git_branch
                other_action.ensure_git_status_clean

                Actions.sh("git remote update")
                local_commit = Actions.sh("git rev-parse HEAD")
                remote_commit = Actions.sh("git rev-parse @{u}")
                UI.abort_with_message! "Your branch is behind 'origin/master' (use \"git pull\" to update your local branch)" unless local_commit == remote_commit

                podspec_version = other_action.version_get_podspec(path: File.expand_path(params[:podspec]))
                project_version = other_action.get_version_number(xcodeproj: File.expand_path(params[:xcodeproj]))
                UI.abort_with_message! "Podspec version (#{podspec_version}) does not match project version (#{project_version})" unless podspec_version == project_version

                if params[:version]
                    version = other_action.version_bump_podspec(
                        path: File.expand_path(params[:podspec]),
                        version_number: params[:version]
                    )
                else
                    version = other_action.version_bump_podspec(
                        path: File.expand_path(params[:podspec]),
                        bump_type: params[:version_bump_type]
                    )
                end

                other_action.increment_version_number(
                    version_number: version,
                    xcodeproj: File.expand_path(params[:xcodeproj])
                )

                if params[:increment_build_number]
                    if params[:build_number]
                        other_action.increment_build_number(
                            build_number: params[:build_number],
                            xcodeproj: File.expand_path(params[:xcodeproj])
                        )
                    else
                        other_action.increment_build_number(
                            xcodeproj: File.expand_path(params[:xcodeproj])
                        )
                    end
                end

                other_action.commit_version_bump(
                    message: params[:version_bump_commit_message],
                    include: params[:podspec]
                )

                tag = "#{params[:tag_prefix]}#{version}"

                begin
                    other_action.add_git_tag(tag: tag)
                rescue => ex
                    Actions.sh("git reset --hard #{local_commit}")
                    raise
                end

                begin
                    other_action.push_to_git_remote
                rescue => ex
                    Actions.sh("git reset --hard #{local_commit}")
                    other_action.remove_git_tag(tag: tag)
                    raise
                end

                begin
                    other_action.pod_push(
                        path: File.expand_path(params[:podspec]),
                        repo: params[:podspec_repo],
                        allow_warnings: params[:podspec_allow_warnings],
                        sources: params[:podspec_sources]
                    )
                rescue => ex
                    Actions.sh("git reset --hard #{local_commit}")
                    other_action.remove_git_tag(tag: tag)
                    other_action.push_to_git_remote(force: true)
                    raise
                end

            end

            def self.description
                "Automates the steps to create a new release for a framework."
            end

            def self.authors
                ["Cole Dunsby"]
            end

            def self.return_value
                "The new version"
            end

            def self.details
                "Automates the steps to create a new release for a framework."
            end

            def self.available_options
                [
                    FastlaneCore::ConfigItem.new(
                        key: :build_number,
                        env_name: "FL_RELEASE_BUILD_NUMBER",
                        description: "Change to a specific build number",
                        optional: true,
                        type: String
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :increment_build_number,
                        env_name: "FL_RELEASE_INCREMENT_BUILD_NUMBER",
                        default_value: false,
                        description: "Will increment build number if enabled",
                        optional: true,
                        is_string: false
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :podspec,
                        env_name: "FL_RELEASE_PODSPEC",
                        default_value: Dir["*.podspec"].first,
                        default_value_dynamic: true,
                        description: "The path of the podspec file to update",
                        optional: true,
                        type: String,
                        verify_block: proc do |value|
                            UI.user_error!("Could not find podspec at path '#{File.expand_path(value)}'") if !File.exist?(value)
                        end
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :podspec_allow_warnings,
                        env_name: "FL_RELEASE_PODSPEC_ALLOW_WARNINGS",
                        default_value: true,
                        description: "Allow warnings during pod push",
                        optional: true,
                        is_string: false
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :podspec_repo,
                        env_name: "FL_RELEASE_PODSPEC_REPO",
                        default_value: "Trunk",
                        description: "The repo you want to push. Pushes to Trunk by default",
                        optional: true,
                        type: String
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :podspec_sources,
                        env_name: "FL_RELEASE_PODSPEC_SOURCES",
                        default_value: ["https://github.com/CocoaPods/Specs"],
                        description: "The sources of repos you want the pod spec to lint with, separated by commas",
                        optional: true,
                        type: Array
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :tag_prefix,
                        env_name: "FL_RELEASE_TAG_PREFIX",
                        default_value: "",
                        description: "A prefix to be added to the version tag (e.g \"v/\")",
                        optional: true,
                        type: String
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :version,
                        env_name: "FL_RELEASE_VERSION",
                        conflicting_options: [:version_bump_type],
                        description: "Change to a specific version. This will replace the bump type value",
                        optional: true,
                        type: String
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :version_bump_commit_message,
                        env_name: "FL_RELEASE_VERSION_BUMP_COMMIT_MESSAGE",
                        default_value: "[FASTLANE] Version bump",
                        description: "The commit message when committing the version bump",
                        optional: true,
                        type: String
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :version_bump_type,
                        env_name: "FL_RELEASE_VERSION_BUMP_TYPE",
                        conflicting_options: [:version],
                        default_value: "patch",
                        description: "The type of this version bump. Available: patch, minor, major",
                        optional: true,
                        type: String,
                        verify_block: proc do |value|
                            UI.user_error!("Available values are 'patch', 'minor' and 'major'") unless ['patch', 'minor', 'major'].include?(value)
                        end
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :xcodeproj,
                        env_name: "FL_RELEASE_XCODEPROJ",
                        default_value: Dir["*.xcodeproj"].first,
                        default_value_dynamic: true,
                        description: "The path of the xcode project to update",
                        optional: true,
                        type: String,
                        verify_block: proc do |value|
                            UI.user_error!("Could not find xcode project at path '#{File.expand_path(value)}'") if !File.exist?(value)
                        end
                    )
                ]
            end

            def self.is_supported?(platform)
                [:ios, :mac].include?(platform)
            end
        end
    end
end
