require 'java_buildpack/component/base_component'
require 'java_buildpack/framework'
require 'java_buildpack/util/dash_case'
require 'java_buildpack/util/java_main_utils'
require 'java_buildpack/util/qualify_path'
require 'java_buildpack/util/spring_boot_utils'
require 'digest'
require "net/http"
require 'net/https'
require "uri"

module JavaBuildpack
  module Framework
    # Encapsulates the detect, compile, and release functionality for applications running a Snyk integration
    class Snyk < JavaBuildpack::Component::BaseComponent
      LIB_DIR = "/tmp/app/WEB-INF/lib"

      def initialize(context, &version_validator)
        super(context, &version_validator)
        @mvn_org_base_api = context[:configuration]['mvn_org_base_api']
        @vunl_service_base_api = context[:configuration]['vunl_service_base_api']
      end

      # (see JavaBuildpack::Component::BaseComponent#detect)
      def detect
        puts "My Snyk detect"
        puts "mvn_org_base_api: #{@mvn_org_base_api}"
        puts "vunl_service_base_api: #{@vunl_service_base_api}"
        Dir.chdir(LIB_DIR)
        dir =  Dir.pwd
        Dir.glob("*").each do |file|
          file_path = "#{dir}/#{file}"
          sha1_hash = sha1_for(file_path)
          mvn_dependency_info(sha1_hash)
        end
        "Snyk"
      end

      private

      def sha1_for(file_path)
        puts file_path
        sha1 = Digest::SHA1.file file_path
        sha1_hash = sha1.hexdigest
        puts "Checksum SHA1: #{sha1_hash}"
        sha1_hash
      end

      def mvn_dependency_info(sha1_hash)
        uri = URI.parse(@mvn_org_base_api)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new("/solrsearch/select?q=1:'#{sha1_hash}'&wt=json")
        response = http.request(request)
        json = JSON.parse(response.body, symbolize_names: true)
        puts "Response:"
        puts json
        json
      end
    end
  end
end