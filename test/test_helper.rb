ENV["RAILS_ENV"] = "internal_test"
ENV['DATABASE_URL'] = 'sqlite3://localhost/:memory:'
require 'bundler/setup'
require 'minitest/autorun'

require "rails"
case Rails.version
when /3\../
  require 'test/unit'
  require "apps/rails3/my_app"
when /4\../
  require "apps/rails4/my_app"
end

require 'rails/test_help'
require 'rack/metrics'



ActiveRecord::Schema.define do
  create_table :posts do |t|
  end

  create_table :comments do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base; end
class Comment < ActiveRecord::Base; end

