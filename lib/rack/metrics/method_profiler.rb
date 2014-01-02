require 'benchmark'
module Rack
  module Metrics
    class MethodProfiler
      def self.profile_method(klass, method, type = :profile, &block)
        method_name = method.to_s.gsub(/[\?\!]/, "")
        with_profiling =  ("#{method_name}_with_profiler").to_sym
        without_profiling = ("#{method_name}_without_profiler").to_sym
        klass.send :alias_method, without_profiling, method
        klass.send :define_method, with_profiling do |*args, &orig|
          name = method.to_s
          if block
            name =
              if respond_to?(:instance_exec)
                instance_exec(*args, &block)
              else
                block.bind(self).call(*args)
              end
          end
          profiler_result = nil
          start = Time.now
          profiler_result = self.send without_profiling, *args, &orig
          duration = (Time.now - start).to_f * 1000
          profiler_result
        end
        klass.send :alias_method, method, with_profiling
      end
    end
  end
end