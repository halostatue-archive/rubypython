require 'rspec/core/rake_task'
require 'yard'

desc "Run all examples"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = '-t ~@slow' unless ENV['filter'] == 'none'
end

desc "Run all examples with RCov"
RSpec::Core::RakeTask.new('spec:rcov') do |t|
  t.pattern = 'spec/**/*.rb'
  t.rspec_opts = '--tag ~slow:true' unless ENV['filter'] == 'none'
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

YARD::Rake::YardocTask.new do |t|
  t.options = [ '--markup','markdown', '--title', 'RubyPython Documentation' ]
end

Dir['tasks/**/*.rake'].each { |rake| load rake }
