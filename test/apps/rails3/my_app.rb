require 'rails/all'
require 'action_view/testing/resolvers'
require 'rack/metrics'

class MyApp < Rails::Application
  config.root = File.expand_path("../../..", __FILE__)
  config.cache_classes = true

  config.eager_load = false
  config.serve_static_assets  = true
  config.static_cache_control = "public, max-age=3600"

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_dispatch.show_exceptions = false

  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :stderr

  config.middleware.delete "Rack::Lock"
  config.middleware.delete "ActionDispatch::Flash"
  config.middleware.delete "ActionDispatch::BestStandardsSupport"
  config.secret_token = "49837489qkuweoiuoqwehisuakshdjksadhaisdy78o34y138974xyqp9rmye8yrpiokeuioqwzyoiuxftoyqiuxrhm3iou1hrzmjk"
  routes.append do
    get "/:action" => "site#:action"
  end
end

Rack::Metrics.config.environments = [:internal_test]
class SiteController < ActionController::Base
  include Rails.application.routes.url_helpers
  layout 'application'
  self.view_paths = [ActionView::FixtureResolver.new(
      "site/simple.html.erb"=> 'Hello from simple.html.erb',
      "site/with_query.html.erb"=> 'Hello from with_query.html.erb',
      "site/with_partial_render.html.erb"=> 'Hello from with_partial_render.html.erb <%= render "comment" %>',
      "site/with_partial_render_with_query.html.erb"=> 'Hello from with_partial_render.html.erb <%= render @comments %>',
      "site/_comment.html.erb"        => "Partial",
      "site/_comment_with_query.html.erb"        => "Partial <%= Comment.count %>",
      "comments/_comment.html.erb"        => "Comment partial",
      "layouts/application.html.erb" => '<%= yield %>',
    )]

  def simple
  end

  def with_query
    post = Post.all.count
  end

  def with_partial_render
    post = Post.all.count
  end

  def with_partial_render_with_query
    post = Post.all.count
    @comments = Comment.all
  end

  def with_template_query
    post = Post.all.count
  end
end

MyApp.initialize!
