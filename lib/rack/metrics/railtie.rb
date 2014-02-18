module Rack
  module Metrics
    class Railtie < Rails::Railtie
      config.after_initialize do
        Metrics.subscribe
      end
    end
  end
end
