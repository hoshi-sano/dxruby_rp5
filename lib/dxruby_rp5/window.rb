# -*- coding: utf-8 -*-
module DXRubyRP5
  module Window
    module_function

    def width
      @width ||= DEFAULTS[:width]
      return @width
    end

    def height
      @height ||= DEFAULTS[:height]
      return @height
    end

    def width=(_width)
      @width = _width
    end

    def height=(_height)
      @height = _height
    end

    def caption
      return $app.frame.get_title
    end

    def caption=(val)
      $app.frame.set_title(val)
    end

    def get_load
      # TODO:
      return 0
    end

    def loop(&block)
      proc = Proc.new do
        background(*DEFAULTS[:background_color])
        block.call
        Window.send(:exec_draw_tasks)
        Input.send(:handle_key_events)
      end

      Processing::App.sketch_class.class_eval { define_method(:draw, proc) }
      @use_window_loop = true
      @queue = []
    end

    def draw(x, y, image, z = 0)
      if @use_window_loop
        draw_task = {
          :proc => lambda { $app.image(image._surface, x, y) },
          :z => z
        }
        @queue << draw_task
      else
        $app.image(image._surface, x, y)
      end
    end

    def draw_ex(x, y, image, hash = {})
      if @use_window_loop
        draw_task = {
          :z => hash[:z] || 0,
          :proc => lambda do
            $app.push_matrix
            $app.translate(x, y)

            if hash[:scale_x] || hash[:scale_y]
              $app.scale(hash[:scale_x] || 1, hash[:scale_y] || 1)
            end
            if hash[:angle]
              $app.rotate($app.radians(hash[:angle]))
            end
            if hash[:alpha]
              $app.tint(255, hash[:alpha])
            end

            $app.image(image._surface, 0, 0)
            $app.no_tint
            $app.pop_matrix
          end,
        }
        @queue << draw_task
      else
        $app.image(image._surface, x, y)
      end
    end


    def draw_font(x, y, string, font, hash = {})
      if string.empty?
        return
      end
      if hash[:color]
        color = $app.color(*hash[:color])
      else
        color = $app.color(255)
      end

      proc = lambda do
        $app.text_size(font.size)
        $app.text_font(font.native)
        $app.fill(color)
        string.lines.each.with_index do |line, i|
          line.chomp!
          if line.empty?
            next
          end
          $app.text(string, x, y)
        end
      end

      if @use_window_loop
        draw_task = {
          :proc => proc,
          :z => hash[:z] || 0,
        }
        @queue << draw_task
      else
        proc.call
      end
    end

    class << self
      alias_method :drawFont, :draw_font

      private

      def exec_draw_tasks
        @queue.sort { |a, b| a[:z] <=> b[:z] }.each do |task|
          task[:proc].call
        end
        @queue.clear
      end
    end

    private

    DEFAULTS = {
      width: 640,
      height: 480,
      background_color: [0, 0, 0],
    }
    private_constant :DEFAULTS
  end
end
