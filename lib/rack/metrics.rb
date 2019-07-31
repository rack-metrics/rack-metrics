require "rack/metrics/version"
require "rack-mini-profiler"
require "net/http"

module Rack
  module Metrics
    class Error < StandardError; end

    class << self
      attr_writer :config

      def config
        @config ||= Rack::Metrics::Config.new
      end

      def enable!
        Rack::MiniProfiler.prepend(Rack::Metrics::Profiler)
      end
    end

    class Config
      attr_accessor :api_key, :environments, :endpoint

      def initialize
        @environments = [:production]
        @endpoint = "http://localhost:3001"
      end
    end

    def self.send_data(page_struct)
      Thread.new do
        # begin
          uri = URI(config.endpoint+'/request')
          res = Net::HTTP.post_form(uri, api_key: config.api_key, data: page_struct.to_json)
        # end
      end
    end

    module FileStore
      def save(page_struct)
        Metrics.send_data(page_struct)
        super
      end
    end

    module Profiler
      def call(env)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        env['RACK_MINI_PROFILER_ORIGINAL_SCRIPT_NAME'] = ENV['PASSENGER_BASE_URI'] || env['SCRIPT_NAME']
        MiniProfiler.create_current(env, @config)
        current.skip_backtrace = false
        status, headers, body = @app.call(env)
        page_struct = current.page_struct
        page_struct[:user] = user(env)
        page_struct[:root].record_time((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000)
        begin
          Metrics.send_data page_struct
        rescue Exception => e
          puts "Something went wrong: #{e.inspect}"
        end
        [status, headers, body]
      ensure
        # Make sure this always happens
        self.current = nil
      end
    end
  end
end
