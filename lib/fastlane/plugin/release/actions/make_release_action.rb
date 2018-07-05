require 'fastlane/action'
require_relative '../helper/make_release_helper'

module Fastlane

    module Actions

        class MakeReleaseAction < Action

            def self.run(params)

                other_action.ensure_git_branch(branch: params[:ensure_git_branch])
                other_action.ensure_git_status_clean if params[:ensure_git_status_clean]

                xcodeproj = File.expand_path(params[:xcodeproj])
                podspec = File.expand_path(params[:podspec])
                version = params[:version]

                if version.nil?
                    version = other_action.version_bump_podspec(path: podspec, bump_type: params[:version_bump_type])
                else
                    other_action.version_bump_podspec(path: podspec, version_number: version)
                end

                other_action.increment_version_number(version_number: version, xcodeproj: xcodeproj)
                other_action.increment_build_number(xcodeproj: xcodeproj) if params[:bump_build]
                other_action.commit_version_bump(include: [params[:podspec]])
                other_action.add_git_tag(tag: params[:tag_prefix] + version)
                other_action.push_to_git_remote

                other_action.pod_push(
                    path: podspec,
                    repo: params[:podspec_repo],
                    allow_warnings: params[:allow_warnings],
                    sources: params[:sources]
                )

                version

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
                        key: :allow_warnings,
                        env_name: "ALLOW_WARNINGS",
                        default_value: true,
                        description: "Allow warnings during pod push",
                        optional: true,
                        type: Boolean
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :bump_build,
                        env_name: "BUMP_BUILD",
                        default_value: false,
                        description: "Will increment build number if enabled",
                        optional: true,
                        type: Boolean
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :ensure_git_branch,
                        env_name: "ENSURE_GIT_BRANCH",
                        default_value: "master",
                        description: "The branch that should be checked for. String that can be either the full name of the branch or a regex to match",
                        optional: true,
                        type: String
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :ensure_git_status_clean,
                        env_name: "ENSURE_GIT_STATUS_CLEAN",
                        default_value: true,
                        description: "Raises an exception if there are uncommitted git changes",
                        optional: true,
                        type: Boolean
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :podspec,
                        env_name: "PODSPEC",
                        description: "The path of the podspec file to update",
                        optional: false,
                        type: String,
                        verify_block: proc do |value|
                            UI.user_error!("Could not find podspec at path '#{File.expand_path(value)}'") if !File.exist?(value)
                        end
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :podspec_repo,
                        env_name: "PODSPEC_REPO",
                        default_value: "Trunk",
                        description: "The repo you want to push. Pushes to Trunk by default",
                        optional: true,
                        type: String
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :sources,
                        env_name: "SOURCES",
                        default_value: ["https://github.com/CocoaPods/Specs"],
                        description: "The sources of repos you want the pod spec to lint with, separated by commas",
                        optional: true,
                        type: Array
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :tag_prefix,
                        env_name: "TAG_PREFIX",
                        default_value: "",
                        description: "A prefix to be added to the version tag (e.g \"v/\")",
                        optional: true,
                        type: String
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :version,
                        env_name: "VERSION",
                        conflicting_options: [:version_bump_type],
                        description: "Change to a specific version. This will replace the bump type value",
                        optional: true,
                        type: String
                    ),
                    FastlaneCore::ConfigItem.new(
                        key: :version_bump_type,
                        env_name: "VERSION_BUMP_TYPE",
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
                        env_name: "XCODEPROJ",
                        description: "The path of the xcode project to update",
                        optional: false,
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
