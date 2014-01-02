module Rack
  module Metrics
    class Railtie < Rails::Railtie
      initializer "rack-metrics.configure_rails_initialization" do |app|
        app.middleware.insert(0, Rack::Metrics::Middleware)
        ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |*args|
          event = ActiveSupport::Notifications::Event.new *args
          Metrics.create_current(event)
        end

        ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
          event = ActiveSupport::Notifications::Event.new *args
          Metrics.current.status = event.payload[:status]
          begin
            Metrics.current.view_runtime = event.payload[:view_runtime].round(2)
            Metrics.current.db_runtime = event.payload[:db_runtime
              ].round(2)
          rescue
          end
          Metrics.current.duration = event.duration.round(2)
          memory = `ps -o rss -p #{Process::pid}`.chomp.split("\n").last.strip.to_i / 1024
          Metrics.current.memory = memory.to_i
          data = [Metrics.current].to_json
          env = Metrics.current.env
          thread = Thread.new do
            Metrics.push_data(data, env)
          end
        end
        ActiveSupport::Notifications.subscribe "render_template.action_view" do |*args|
          unless Metrics.current.nil?
            event = ActiveSupport::Notifications::Event.new *args
            event.payload[:identifier].gsub!("#{Rails.root}/", '') unless event.payload[:identifier].nil?
            Metrics.current.template.name = event.name
            Metrics.current.template.duration = event.duration.round(2)
            Metrics.current.template.data = event.payload
            Metrics.current.template.children = Metrics.current.partials
            Metrics.current.template.queries.concat(Metrics.current.queries)
          end
        end

        ActiveSupport::Notifications.subscribe "render_partial.action_view" do |*args|
          unless Metrics.current.nil?
            event = ActiveSupport::Notifications::Event.new *args
            Metrics.current.partials<< Metrics::RenderEvent.new(event, Metrics.current.queries, true)
            Metrics.current.queries = []
          end
        end

        ActiveSupport::Notifications.subscribe "sql.active_record" do |*args|
          unless Metrics.current.nil?
            event = ActiveSupport::Notifications::Event.new *args
            Metrics.current.queries<< QueryEvent.new(event, Metrics.parse_stack(caller(2)).join("\r\n")) unless event.payload[:name].eql?('SCHEMA')
          end
        end

        ActiveSupport::Notifications.subscribe "start_render_partial.action_view" do |*args|
          unless Metrics.current.nil?
            Metrics.current.template.queries.concat(Metrics.current.queries)
            Metrics.current.queries = []
          end
        end
      end
    end
  end
end
