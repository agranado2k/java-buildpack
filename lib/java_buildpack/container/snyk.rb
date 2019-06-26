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
      # (see JavaBuildpack::Component::BaseComponent#detect)
      def detect
        puts "My Snyk detect"
        Dir.chdir("/tmp/app/WEB-INF/lib")
        puts Dir.pwd
        puts Dir.glob("*")
        nil
      end
    end
  end
end