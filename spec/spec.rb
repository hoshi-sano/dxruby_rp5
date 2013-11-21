# -*- coding: utf-8 -*-
spec_root = File.dirname(__FILE__)
rspec_libs_path =  File.join(spec_root, "vendor/*/lib")
Dir.glob(rspec_libs_path).each do |path|
  $LOAD_PATH << path
end

Dir.glob(File.expand_path('../support/**/*.rb', __FILE__)).each do |path|
  require path
end

require 'rspec'

dxrp5_specs = Dir.glob(File.join(spec_root, "lib/**/*"))
RSpec::Core::Runner.run(dxrp5_specs)
