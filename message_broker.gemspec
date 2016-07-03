# encoding: UTF-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'message_broker/version'

Gem::Specification.new do |spec|
  spec.name          = 'message_broker'
  spec.version       = MessageBroker::VERSION
  spec.authors       = ['Developer']
  spec.email         = ['developer@email.com']

  spec.summary       = 'Test challenge'
  spec.description   = 'This is a test challenge'
  spec.homepage      = 'https://developer.website.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'pry', '~> 0.10.3'
end
