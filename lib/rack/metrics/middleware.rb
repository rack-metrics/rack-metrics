module Rack
  module Metrics
    class Middleware
      def initialize(app)
        @app = app
      end
      def call(env)
        status, headers, body = @app.call(env)
        [status, headers, body]
      end
    end
  end
end


