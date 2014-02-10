module Rack
  module Metrics
    class Railtie < Rails::Railtie
      initializer "rack-metrics.configure_rails_initialization" do |app|
        Metrics.subscribe
      end
    end
  end
end
