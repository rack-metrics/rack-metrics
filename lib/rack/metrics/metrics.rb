require 'net/http'
require 'json'
module Rack
  module Metrics
    class << self
      attr_writer :config

      def config
        @config ||= Rack::Metrics::Config.new
      end

      def current
        Thread.current[:rack_metrics]
      end

      def create_current(data)
        self.current = Metrics::Request.new(data)
      end

      def current=(c)
        Thread.current[:rack_metrics] = c
      end

      def push_data(data, env)
        return unless Rack::Metrics.config.environments.include?(env.to_sym)
        @endpoint = 'https://rack-metrics.com/api/v1/metrics'
        log("=> Pushing metrics data")
        begin
          uri = URI(@endpoint)
          res = Net::HTTP.post_form(uri, 'api_key' => Rack::Metrics.config.api_key, 'data' => data)
        rescue => e
          log "=> Error while pushing metrics data: #{e.message}"
        end
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