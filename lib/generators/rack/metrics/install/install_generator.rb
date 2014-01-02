module Rack
	module Metrics
		class InstallGenerator < Rails::Generators::Base
		  desc "This generator creates an initializer file at config/initializers"
		  def create_initializer
		    create_file "config/initializers/rack-metrics.rb", "Rack::Metrics.config.api_key = 'api_key_goes_here'"
		  end

		end
	end
end