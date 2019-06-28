require 'java_buildpack/component/base_component'
require 'java_buildpack/framework'
require 'java_buildpack/util/dash_case'
require 'java_buildpack/util/java_main_utils'
require 'java_buildpack/util/qualify_path'
require 'java_buildpack/util/spring_boot_utils'
require 'java_buildpack/logging/logger_factory'
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
        @logger                = JavaBuildpack::Logging::LoggerFactory.instance.get_logger Snyk
      end

      # (see JavaBuildpack::Component::BaseComponent#detect)
      def detect
        vuln = []
        @logger.info { "Checking dependencies for vulnerabilities..." }
        Dir.chdir(LIB_DIR)
        dir =  Dir.pwd
        Dir.glob("*").each do |file|
          file_path = "#{dir}/#{file}"
          sha1_hash = sha1_for(file_path)
          package_info = mvn_dependency_info(sha1_hash)
          vuln = vuln.concat(vulnerabilities(package_info))
        end
        @logger.debug { "vulnerabilities: #{vuln}" }
        raise RuntimeError, "Found vulnerabilities: #{vuln.join(', ')}" unless vuln.empty?
        nil
      end

      def compile; end

      def release; end

      private

      def sha1_for(file_path)
        sha1 = Digest::SHA1.file file_path
        sha1.hexdigest
      end

      def mvn_dependency_info(sha1_hash)
        uri = URI.parse(@mvn_org_base_api)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new("/solrsearch/select?q=1:#{sha1_hash}&wt=json")
        response = http.request(request)
        format_mvn_response(JSON.parse(response.body, symbolize_names: true))
      end

      def format_mvn_response(json)
        response = json[:response][:docs][0]
        return nil unless response

        {group_id: response[:g], artifact_id: response[:a], version: response[:v]}
      end

      def vulnerabilities(package)
        return [] unless package

        uri = URI.parse(@vunl_service_base_api)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        @logger.info { "package: #{package[:group_id]}:#{package[:artifact_id]}:#{package[:version]}" }
        request = Net::HTTP::Get.new("/vulnerabilities?group_id=#{package[:group_id]}&artifact_id=#{package[:artifact_id]}&version=#{package[:version]}")
        response = http.request(request)
        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end