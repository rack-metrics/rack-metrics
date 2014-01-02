require 'test_helper'

class ProfilerTest < MiniTest::Unit::TestCase
  require 'support/classes/foo'
  def test_it_adds_profiler_method
    Rack::Metrics::MethodProfiler.profile_method(Foo, :bar) {|action| "Executing action: #{action}"}
    assert_includes Foo.instance_methods, :bar
    assert_includes Foo.instance_methods, :bar_without_profiler
    assert_includes Foo.instance_methods, :bar_with_profiler
  end

  def test_it_returns_what_needs
    Rack::Metrics::MethodProfiler.profile_method(Foo, :bar) {|action| "Executing action: #{action}"}
    f = Foo.new
    assert_equal 'foobar', f.bar
  end
end