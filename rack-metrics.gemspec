# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/metrics/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-metrics"
  spec.version       = Rack::Metrics::VERSION
  spec.authors       = ["Greg Molnar"]
  spec.email         = ["molnargerg@gmail.com"]
  spec.description   = %q{rack-metrics is a performance monitoring tool.}
  spec.summary       = %q{A performance monitoring tool.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency "rake"
end
