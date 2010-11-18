require 'spec/rake/spectask'
require 'yard'

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('spec:rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

YARD::Rake::YardocTask.new do |t|
  t.options = [ '--markup','markdown', '--title', 'RubyPython Documentation' ]
end

Dir['tasks/**/*.rake'].each { |rake| load rake }
