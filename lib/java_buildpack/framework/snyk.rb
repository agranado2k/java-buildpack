require 'java_buildpack/component/base_component'
require 'java_buildpack/framework'
require 'java_buildpack/util/dash_case'
require 'java_buildpack/util/java_main_utils'
require 'java_buildpack/util/qualify_path'
require 'java_buildpack/util/spring_boot_utils'
require 'digest'
require "net/http"
require "uri"

module JavaBuildpack
  module Framework
    # Encapsulates the detect, compile, and release functionality for applications running a Snyk integration
    class Snyk < JavaBuildpack::Component::BaseComponent
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
        Dir.chdir("/tmp/app/WEB-INF/lib")
        dir =  Dir.pwd
        Dir.glob("*").each do |file|
          file_path = "#{dir}/#{file}"
          puts file_path
          sha1 = Digest::SHA1.file file_path
          sha1_hash = sha1.hexdigest
          puts "Checksum SHA1: #{ sha1_hash}"

          url = "#{@mvn_org_base_api}/solrsearch/select?q=1:'#{sha1_hash}'&wt=json"
          uri = URI.parse(url)
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new("/search?question=somequestion")
          response = http.request(request)
          json = JSON.parse(response.body, symbolize_names: true)
          puts "Response:"
          puts json
        end
        "Snyk"
      end
    end
  end
end