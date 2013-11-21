# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dxruby_rp5/version'

Gem::Specification.new do |spec|
  spec.name          = "dxruby_rp5"
  spec.version       = DXRubyRP5::VERSION
  spec.authors       = ["Yuki Morohoshi"]
  spec.email         = ["hoshi.sanou@gmail.com"]
  spec.description   = %q{`dxruby-rp5` is a ruby library for 2D graphics and game. `dxruby-rp5` uses `ruby-processing` and  has API same as DXRuby.}
  spec.summary       = %q{2D graphics and game library}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "ruby-processing", ">= 2.0"
end
