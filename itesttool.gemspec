# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itesttool/version'
require 'rake'

Gem::Specification.new do |spec|
  spec.name          = "itesttool"
  spec.version       = Itesttool::VERSION
  spec.authors       = ["bati11"]
  spec.email         = ["mail.bati11@gmail.com"]
  spec.description   = %q{End-to-End Test tool for web api.}
  spec.summary       = %q{End-to-End Test tool for web api.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Rake::FileList['lib/**/*', 'Rakefile', 'Gemfile', 'README.md', 'LICENSE.txt'].to_a
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency('rspec', '~> 2.14')
  spec.add_dependency('json-schema', '~> 2.2')
  spec.add_dependency('json', '1.8.1')
  spec.add_dependency('jsonpath', '~> 0.5.5')
  spec.add_dependency('nokogiri', '~> 1.6.1')
  spec.add_development_dependency "sinatra", "~> 1.4"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
