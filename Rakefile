# encoding: utf-8

require 'rspec/core/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'

desc "Run rspec with formatting"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--colour', '--format documentation']
  t.pattern = '*_spec.rb'
end

desc "Generate YARD documentation"
YARD::Rake::YardocTask.new :doc do
end
