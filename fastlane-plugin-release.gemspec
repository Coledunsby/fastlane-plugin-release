# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/release/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-release'
  spec.version       = Fastlane::Release::VERSION
  spec.author        = 'Cole Dunsby'
  spec.email         = 'coledunsby@gmail.com'

  spec.summary       = 'Automates the steps to create a new release for a project.'
  spec.homepage      = "https://github.com/Coledunsby/fastlane-plugin-release"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'fastlane-plugin-remove_git_tag'

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.99.0')
end
