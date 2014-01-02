module Rack
  module Metrics
    class Instrumenter
      def self.instrument_method(klass, method, name)
        method_name = method.to_s.gsub(/[\?\!]/, "")
        with_rack_metrics =  ("#{method_name}_with_rack_metrics").to_sym
        without_rack_metrics = ("#{method_name}_without_rack_metrics").to_sym
        klass.send :alias_method, without_rack_metrics, method
        klass.send :define_method, with_rack_metrics do |*args, &orig|
          ActiveSupport::Notifications.instrument(name)
          self.send without_rack_metrics, *args, &orig
        end
        klass.send :alias_method, method, with_rack_metrics
      end
    end
  end
end