require 'test_helper'
require 'pp'
class MetricsTest < ActiveSupport::TestCase
	def setup
		ActiveSupport::Notifications.instrument('start_processing.action_controller'){}
	end

	test "it subscribes to start_processing.action_controller" do
		assert_kind_of Rack::Metrics::Event, Rack::Metrics.current
		assert_kind_of Rack::Metrics::Event, Rack::Metrics.current.template
	end

	test "it subscribes to sql.active_record" do
		ActiveSupport::Notifications.instrument('sql.active_record'){}
		assert !Rack::Metrics.current.template.queries.empty?
	end

	test "it subscribes to query.moped" do
		ActiveSupport::Notifications.instrument('query.moped'){}
		assert !Rack::Metrics.current.template.queries.empty?
	end

	test "it subscribes to render_template.action_view" do
		ActiveSupport::Notifications.instrument('render_template.action_view'){}
		assert !Rack::Metrics.current.template.nil?
	end

	test "it subscribes to render_partial.action_view" do
		ActiveSupport::Notifications.instrument('start_render_partial.action_view'){}
		ActiveSupport::Notifications.instrument('render_partial.action_view'){}
		assert !Rack::Metrics.current.template.partials.empty?
	end

	test "it nests render_partial.action_view" do
		ActiveSupport::Notifications.instrument('start_render_partial.action_view'){}
		ActiveSupport::Notifications.instrument('render_partial.action_view') do
				ActiveSupport::Notifications.instrument('start_render_partial.action_view'){}
				ActiveSupport::Notifications.instrument('render_partial.action_view') do
					ActiveSupport::Notifications.instrument('start_render_partial.action_view'){}
					ActiveSupport::Notifications.instrument('render_partial.action_view'){}
			end
		end
		assert !Rack::Metrics.current.template.partials.empty?
		assert_equal 1, Rack::Metrics.current.template.partials.count
		assert !Rack::Metrics.current.template.partials[0].partials.empty?
	end

	test "it adds query to nested render_partial.action_view" do
		ActiveSupport::Notifications.instrument('start_render_partial.action_view'){}
		ActiveSupport::Notifications.instrument('render_partial.action_view') do
				ActiveSupport::Notifications.instrument('start_render_partial.action_view'){}
				ActiveSupport::Notifications.instrument('sql.active_record'){}
				ActiveSupport::Notifications.instrument('render_partial.action_view') do
			end
		end
		assert !Rack::Metrics.current.template.partials.empty?
		assert_equal 1, Rack::Metrics.current.template.partials.count
		assert_equal 0, Rack::Metrics.current.template.queries.count
		assert_equal 1, Rack::Metrics.current.template.partials[0].partials[0].queries.count
	end
end
