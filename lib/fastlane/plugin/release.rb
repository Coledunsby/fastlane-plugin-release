require 'fastlane/plugin/release/version'

module Fastlane
    module Release
        def self.all_classes
            Dir[File.expand_path('**/{actions,helper}/*.rb', File.dirname(__FILE__))]
        end
    end
end

Fastlane::Release.all_classes.each do |current|
    require current
end
