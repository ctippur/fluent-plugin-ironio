# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-ironio"
  gem.version       = "0.0.1"
  gem.date          = '2015-01-30'
  gem.authors       = ["chandrashekar Tippur"]
  gem.email         = ["ctippur@gmail.com"]
  gem.summary       = %q{Fluentd input plugin for ironio alerts}
  gem.description   = %q{FLuentd plugin for ironio alerts... WIP}
  gem.homepage      = 'https://github.com/ctippur/fluent-plugin-ironio'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake", '~> 0.9', '>= 0.9.6'
  gem.add_runtime_dependency "fluentd", '~> 0.10', '>= 0.10.51'
  gem.add_runtime_dependency "json", '~> 1.1', '>= 1.8.2'
  gem.add_runtime_dependency "iron_mq", '>= 5.0.1'
end
