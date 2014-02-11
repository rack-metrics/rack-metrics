require "bundler/gem_tasks"
require 'rake/testtask'

require 'appraisal'
Rake::TestTask.new do |t|
  t.libs = ["test"]
  t.pattern = "test/**/*_{spec,test}.rb"

end
task :default => :test
