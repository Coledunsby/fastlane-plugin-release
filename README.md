# release fastlane plugin

[![License](https://img.shields.io/github/license/Coledunsby/fastlane-plugin-release.svg)](https://github.com/Coledunsby/fastlane-plugin-release/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/fastlane-plugin-release.svg?style=flat)](http://rubygems.org/gems/fastlane-plugin-release)
[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-podspec_dependency_versioning)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-release`, add it to your project by running:

```bash
fastlane add_plugin release
```

## About release

Extends fastlane release actions. Automates the steps to create a new release for a framework. At a high level, it goes through these steps:

 - Increments podspec version
 - Increments xcodeproj version
 - Increments xcodeproj build (opt-in)
 - Commits version bumps
 - Tags release
 - Pushes to remote
 - Pushes podspec

The order of these operations depends on the configuration. See below for customization options...

## Actions

### make_release

|parameter|optional|default|description|
|---------|--------|-------|-----------|
|podspec|false||The path of the podspec|
|xcodeproj|true||The path of the xcode project. Required for incrementing version and build number in xcodeproj|
|allow_warnings|true|`true`|Allow warnings during pod push|
|bump_build|true|`false`|Increments the build number; optional|
|ensure_git_branch|true|`"master"`|The branch that should be checked for|
|ensure_git_status_clean|true|`true`|Raises an exception if there are uncommitted git changes|
|podspec_repo|true|`"Trunk"`|The podspec repo|
|post_bump|true|`false`|Bump version number after tag and podspec push|
|pre_bump|true|`false`|Bump version number before tag and podspec push|
|sources|true|`["https://github.com/CocoaPods/Specs"]`|The sources of repos you want the pod spec to lint with|
|tag_prefix|true|`""`|A prefix to be added to the version tag (e.g. "v/")|
|version|true|`nil`|Change to a specific version. Cannot be used in conjuction with version_bump_type|
|version_bump_type|true|`"patch"`|The type of this version bump. Available: patch, minor, major|


A typical use case could look something like this:
```ruby
make_release(
    xcodeproj: "Nitrous.xcodeproj",
    podspec: "Nitrous.podspec",
    podspec_repo: "coledunsby",
    tag_prefix: "v/",
    post_bump: true
)
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
