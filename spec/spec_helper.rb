# -*- coding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ruby-processing'

# redefine Processing::App#initialize so that dose not run sketch.
class Processing::App
  def initialize(options={})
    super()
    $app = self
    proxy_java_fields
    set_sketch_path
    mix_proxy_into_inner_classes

    java.lang.Thread.default_uncaught_exception_handler = proc do |thread, exception|
      puts(exception.class.to_s)
      puts(exception.message)
      puts(exception.backtrace.collect { |trace| "\t" + trace })
      close
    end

    args = []

    @width, @height = options[:width], options[:height]

    if @@full_screen || options[:full_screen]
      @@full_screen = true
      args << "--present"
    end
    @render_mode  ||= JAVA2D
    x = options[:x] || 0
    y = options[:y] || 0
    args << "--location=#{x}, #{y}"

    title = options[:title] || File.basename(SKETCH_PATH).sub(/(\.rb)$/, '').titleize
    args << title
  end
end

sketch_path = File.expand_path('fixtures/test_sketch.rb', File.dirname(__FILE__))
require sketch_path

Processing::App.const_set(:SKETCH_PATH, sketch_path)

require 'dxruby'
require 'dxruby_rp5'
