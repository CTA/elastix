# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elastix/version'

Gem::Specification.new do |spec|
  spec.name          = "elastix"
  spec.version       = Elastix::VERSION
  spec.authors       = ["David Hahn"]
  spec.email         = ["dhahn@ctatechs.com"]
  spec.description   = %q{ A wrapper of the Elastix Call Center Module that deals primarily with extension management.}
  spec.summary       = %q{ Elastix is a gem that simplifies the process of creating, removing and changing extensions in the elastix web interface.}
  spec.homepage      = "https://github.com/CTA/elastix"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'mechanize', '~> 2.7' 
  spec.add_dependency 'activerecord', '~> 3.2' 
  spec.add_dependency 'mysql2'
end
