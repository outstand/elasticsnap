# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elasticsnap/version'

Gem::Specification.new do |spec|
  spec.name          = "elasticsnap"
  spec.version       = Elasticsnap::VERSION
  spec.authors       = ["Ryan Schlesinger"]
  spec.email         = ["ryan@aceofsales.com"]
  spec.description   = %q{Consistent snapshots for elasticsearch}
  spec.summary       = %q{Consistent snapshots for elasticsearch with a focus on EBS snapshots}
  spec.homepage      = "https://github.com/aceofsales/elasticsnap"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'fog', '~> 1.15'
  spec.add_dependency 'thor', '~> 0.18.1'
  spec.add_dependency 'flex', '~> 1.0.4'
  spec.add_dependency 'rest-client', '~> 1.6.7'
  spec.add_dependency 'capistrano', '~> 2.15.5'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "webmock"
end
