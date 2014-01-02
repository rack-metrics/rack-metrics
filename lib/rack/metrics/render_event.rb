module Rack
  module Metrics
    class RenderEvent
      attr_accessor :name, :duration, :started, :data, :children, :partial, :queries

      def initialize(event, queries = [], partial = false)
        unless event.nil?
          data = event.payload.dup
          data[:identifier].gsub!("#{Rails.root}/", '') unless data[:identifier].nil?
          @name = event.name
          @duration = event.duration.round(2)
          @data = data
        end
        @partial = partial
        @children = []
        @queries = queries
      end
    end
  end
end