require "rack/metrics/instrumenter"
require "rack/metrics/version"
require "rack/metrics/middleware"
require "rack/metrics/config"
require "rack/metrics/metrics"
require "rack/metrics/request"
require "rack/metrics/render_event"
require "rack/metrics/query_event"
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
  end
end

Rack::Metrics::Instrumenter.instrument_method(ActionView::PartialRenderer, :render, "start_render_partial.action_view")
