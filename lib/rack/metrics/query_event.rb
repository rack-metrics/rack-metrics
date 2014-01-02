module Rack
  module Metrics
    class QueryEvent
      attr_accessor :name, :duration, :data, :query, :stack_trace

      def initialize(event, stack_trace)
        @name = event.payload[:name]
        @duration = event.duration.round(2)
        @query = event.payload[:sql]
        @stack_trace = stack_trace
      end

    end
  end
end