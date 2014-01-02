module Rack
  module Metrics
    class Current
      attr_accessor :templates, :partials, :queries

      def initialize
        @templates = []
        @partials = []
        @queries = []
      end
    end
  end
end