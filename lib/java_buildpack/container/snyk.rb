require 'java_buildpack/component/base_component'
require 'java_buildpack/container'
require 'java_buildpack/util/dash_case'
require 'java_buildpack/util/java_main_utils'
require 'java_buildpack/util/qualify_path'
require 'java_buildpack/util/spring_boot_utils'
require 'digest'

module JavaBuildpack
  module Container
    # Encapsulates the detect, compile, and release functionality for applications running a Snyk integration
    class Snyk < JavaBuildpack::Component::BaseComponent
      # (see JavaBuildpack::Component::BaseComponent#detect)
      def detect
        puts "My Snyk detect"
        Dir.chdir("/tmp/app/WEB-INF/lib")
        dir =  Dir.pwd
        Dir.glob("*").each do |file|
          file_path = "#{dir}/#{file}"
          puts file_path
          sha1 = Digest::SHA1.file file_path
          puts "Checksum SHA1: #{sha1.hexdigest}"
        end
        nil
      end
    end
  end
end