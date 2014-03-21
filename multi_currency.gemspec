# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_currency/version'

Gem::Specification.new do |spec|
  spec.name          = "multi_currency"
  spec.version       = MultiCurrency::VERSION
  spec.authors       = ["Rijaludin Muhsin"]
  spec.email         = ["rijaludinmuhsin@gmail.com"]
  spec.summary       = "Library for multi currency support"
  spec.description   = "Provide various functions to support multi currency in activerecord object."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
