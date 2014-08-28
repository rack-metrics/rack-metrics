require 'net/http'
require 'json'
module Rack
  module Metrics
    class << self
      attr_writer :config
      attr_accessor :start_processing

      def config
        @config ||= Rack::Metrics::Config.new
      end

      def current
        Thread.current[:rack_metrics]
      end

      def current=(c)
        Thread.current[:rack_metrics] = c
      end

      def push_data(data)
        return if ENV['RACK_METRICS_API_KEY'].blank?
        log("[Rack Metrics] => Pushing metrics data")
        begin
          uri = URI(::File.join(Rack::Metrics.config.endpoint, 'api/v1'))
          res = Net::HTTP.post_form(uri, 'api_key' => ENV['RACK_METRICS_API_KEY'], 'api_version' => '1.1.0', 'data' => data)
        rescue => e
          log "[Rack Metrics] => Error while pushing metrics data: #{e.message}"
        end
        Metrics.current = nil
      end

      def log(message)
        begin
          Rails.logger.info message
        rescue
          puts message
        end
      end
    end

    def current
      Metrics.current
    end

    def current=(c)
      Metrics.current = c
    end
  end
end
