# -*- coding: utf-8 -*-
require 'ruby-processing'
require "#{RP5_ROOT}/lib/ruby-processing/runners/base.rb"

module Processing
  KEY_METHODS = <<-EOS
    def key_pressed
      Input.send(:key_pressed, key, key_code)
      Input.send(:key_pushed, key, key_code)
    end

    def key_released
      Input.send(:key_released, key, key_code)
    end
  EOS

  MOUSE_METHODS = <<-EOS
    def mouse_pressed(event)
      Input.send(:mouse_pressed, event.get_button)
      Input.send(:mouse_pushed, event.get_button)
    end

    def mouse_released(event)
      Input.send(:mouse_released, event.get_button)
    end
  EOS

  SKETCH_TEMPLATE_FOR_RP5 = <<-EOS
    class Sketch < Processing::App
      <% if has_methods %>
      <%= source %>
      <% else %>
      def setup
        size(DEFAULT_WIDTH, DEFAULT_HEIGHT, JAVA2D)
        <%= source %>
        no_loop
      end
      <% end %>
      <% if !has_key_methods %>
      #{KEY_METHODS}
      <% end %>

      <% if !has_mouse_methods %>
      #{MOUSE_METHODS}
      <% end %>
    end
  EOS

  SKETCH_TEMPLATE_FOR_DXRUBY_RP5 = <<-EOS
    class Sketch < Processing::App
      def setup
        <%= source %>
        size(Window.width, Window.height, JAVA2D)
      end

      def draw
      end

      <% if !has_key_methods %>
      #{KEY_METHODS}
      <% end %>

      <% if !has_mouse_methods %>
      #{MOUSE_METHODS}
      <% end %>
    end
  EOS

  def self.load_and_run_sketch
    source = self.read_sketch_source
    has_sketch = !!source.match(/^[^#]*< Processing::App/)
    has_methods = !!source.match(/^[^#]*(def\s+setup|def\s+draw)/)
    has_window_loop = !!source.match(/^[^#]*(Window\.loop\sdo)/)
    has_key_methods = !!source.match(/^[^#]*(def\s+(key_pressed|key_typed|key_released))/)
    has_mouse_methods = !!source.match(/^[^#]*(def\s+(mouse_pressed|mouse_released))/)

    if has_sketch
      load File.join(SKETCH_ROOT, SKETCH_PATH)
      Processing::App.sketch_class.new if !$app
    else
      require 'erb'
      code = has_window_loop ?
        ERB.new(SKETCH_TEMPLATE_FOR_DXRUBY_RP5).result(binding) :
        ERB.new(SKETCH_TEMPLATE_FOR_RP5).result(binding)
      Object.class_eval code, SKETCH_PATH, -1
      Processing::App.sketch_class.new
    end
  end
end
