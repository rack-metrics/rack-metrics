module Rack
  module Metrics
    class Config
      attr_accessor :api_key, :environments, :endpoint

      def initialize
        @environments = [:production]
        @endpoint = "https://rack-metrics.com"
      end
    end
  end
end
