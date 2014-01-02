module Rack
  module Metrics
    class Request < OpenStruct
      attr_accessor :name, :controller, :action, :params, :format, :method, :path, :duration, :started, :template, :partials, :queries, :status, :view_runtime, :db_runtime, :memory, :env

      def initialize(event)
        @name = event.name
        @duration = event.duration
        @started = Time.now
        @env = Rails.env || ENV['rack_env']
        @controller = event.payload[:controller]
        @action = event.payload[:action]
        @method = event.payload[:method]
        @path = event.payload[:path]
        @format = event.payload[:format]
        @status = event.payload[:status]
        @view_runtime = event.payload[:view_runtime]
        @db_runtime = event.payload[:db_runtime]
        @children = []
        @partials = []
        @queries = []
        @template = Metrics::RenderEvent.new(nil, [])
      end
    end
  end
end


