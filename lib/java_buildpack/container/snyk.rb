require 'java_buildpack/component/base_component'
require 'java_buildpack/container'
require 'java_buildpack/util/dash_case'
require 'java_buildpack/util/java_main_utils'
require 'java_buildpack/util/qualify_path'
require 'java_buildpack/util/spring_boot_utils'

module JavaBuildpack
  module Container
    # Encapsulates the detect, compile, and release functionality for applications running a Snyk integration
    class Snyk < JavaBuildpack::Component::BaseComponent
      def initialize(context)
        puts "context:"
        puts "Application"
        puts context[:application]
        puts "space_case"
        puts self.class.to_s.space_case
        puts "Application"
        puts context[:configuration]
        puts "Droplet"
        puts context[:droplet]
        super(context)
      end

      # (see JavaBuildpack::Component::BaseComponent#detect)
      def detect
        puts "My Snyk detect"
        nil
      end
    end
  end
end