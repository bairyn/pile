# encoding: utf-8
$:.push File.expand_path("..", __FILE__)
require 'lib/pile'

Gem::Specification.new do |s|
  s.name = 'pile'
  s.version = Pile::VERSION
  s.authors = ['Byron Johnson']
  s.email = ['byron@byronjohnson.net']
  s.homepage = 'https://github.com/bairyn/pile'
  s.summary = %q{CSV file manipulation library.}
  s.description = %q{pile provides classes for updating, reading, and writing CSV files that consist of a header and a number of records.}
  s.license = 'BSD3'

  s.add_dependency 'rspec'

  s.files = ['Rakefile'] + Dir['lib/**/*.rb']
  s.test_files = Dir['spec/**/*.rb']
  s.require_paths = ['lib']
end
