require "rack/metrics/instrumenter"
require "rack/metrics/version"
require "rack/metrics/middleware"
require "rack/metrics/config"
require "rack/metrics/metrics"
require "rack/metrics/current"
require "rack/metrics/railtie" if defined? Rails

module Rack
  module Metrics
    def self.parse_stack(stack)
      parsed = []
      stack.each do |line|
        line.gsub!("#{Rails.root}/", '')
        if /^((?:app|config|lib|test).+?):(\d+)(?::in `(.*)')?/ =~ line
          parsed<< line
        end
      end
      parsed
    end

    def self.subscribe
      ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |*args|
        Metrics.current = Event.new *args
        Metrics.current.stack = Stack.new
        Metrics.current.template = Event.new *args

        ActiveSupport::Notifications.subscribe "render_template.action_view" do |name, time, finished, transaction_id, payload|
          Metrics.current.template.name = name
          Metrics.current.template.time = time
          Metrics.current.template.end = finished
          Metrics.current.template.transaction_id = transaction_id
          Metrics.current.template.payload = payload
          Metrics.current.template.payload[:identifier] = Metrics.current.template.payload[:identifier].gsub("#{Rails.root}/", '') unless Metrics.current.template.payload[:identifier].nil?
        end
      end

      ActiveSupport::Notifications.subscribe "render_template.action_view" do |name, time, finished, transaction_id, payload|
        Metrics.current.template.name = name
        Metrics.current.template.time = time
        Metrics.current.template.end = finished
        Metrics.current.template.transaction_id = transaction_id
        Metrics.current.template.payload = payload
        Metrics.current.template.payload[:identifier] = Metrics.current.template.payload[:identifier].gsub("#{Rails.root}/", '') unless Metrics.current.template.payload[:identifier].nil?
      end

      ActiveSupport::Notifications.subscribe "start_render_partial.action_view" do |*args|
        # TODO: make it work with nested render partials
        render_partial = Event.new *args
        Metrics.current.stack<< render_partial
      end

      ActiveSupport::Notifications.subscribe "render_partial.action_view" do |*args|
        render_partial = Metrics.current.stack.pop
        render_partial.init *args
        render_partial.payload[:identifier] = render_partial.payload[:identifier].gsub("#{Rails.root}/", '') unless render_partial.payload[:identifier].nil?
        if Metrics.current.stack.empty?
          Metrics.current.template.partials<< render_partial
        else
          Metrics.current.stack.peek.partials<< render_partial
        end
      end

      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, time, finished, transaction_id, payload|
        Metrics.current.name = name
        Metrics.current.time = time
        Metrics.current.end = finished
        Metrics.current.transaction_id = transaction_id
        Metrics.current.payload = payload
        memory = `ps -o rss -p #{Process::pid}`.chomp.split("\n").last.strip.to_i / 1024
        Metrics.current.payload['memory'] = memory.to_i
        begin
          env = Rails.env || ENV['rack_env']
          data = Metrics.current.to_json
          thread = Thread.new do
            Metrics.push_data(data, env)
          end
        rescue Exception => e
          Metrics.log("Rack-Metrics exception raised: #{e.inspect}")
        end
      end

      ActiveSupport::Notifications.subscribe "sql.active_record" do |*args|
        sql = Event.new *args
        if Metrics.current.is_a?(Rack::Metrics::Event)
          unless sql.payload[:name] == 'SCHEMA'
            sql.payload['stacktrace'] = Metrics.parse_stack(caller(2)).join("\r\n")
            if Metrics.current.stack.empty?
              Metrics.current.template.queries<< sql
            else
              Metrics.current.stack.peek.queries<< sql
            end
          end
        end
      end
    end
  end
end

Rack::Metrics::Instrumenter.instrument_method(ActionView::PartialRenderer, :render, "start_render_partial.action_view")

module Rack
  module Metrics
    class Event < ActiveSupport::Notifications::Event
      attr_accessor :template, :queries, :partials, :name, :time, :end, :transaction_id, :payload, :stack

      def initialize(name, start, ending, transaction_id, payload)
        @queries = []
        @partials = []
        super(name, start, ending, transaction_id, payload)
      end

      def init(name, start, ending, transaction_id, payload)
        @name           = name
        @payload        = payload.dup
        @time           = start
        @transaction_id = transaction_id
        @end            = ending
      end

      def as_json(options={})
        attrs = super(options)
        attrs['duration'] = self.duration.round(2)
        attrs.delete_if {|k, v| v.nil?}
        attrs.delete_if {|k, v| v.respond_to?(:empty?) and v.empty? }
        attrs
      end
    end

    class Stack

      def initialize
        @storage = []
      end

      def push(e)
        @storage.push e
      end
      alias_method :<<, :push

      def pop
        @storage.pop
      end

      def peek
        @storage.last
      end

      def first
        @storage.first
      end

      def empty?
        @storage.empty?
      end
    end

  end
end


