module Rack
	module Metrics
		class InstallGenerator < Rails::Generators::Base
		  desc "This generator creates an initializer file at config/initializers"
		  def create_initializer
		    create_file "config/initializers/rack-metrics.rb", "ENV['RACK_METRICS_API_KEY'] = 'api_key_goes_here'"
		  end

		end
	end
end