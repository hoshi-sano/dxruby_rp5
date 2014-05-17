# -*- coding: utf-8 -*-
module DXRubyRP5
  class RenderTarget
    attr_reader :bgcolor
    attr_reader :_surface

    def initialize(width, height, _bgcolor = [0, 255, 255, 255])
      _bgcolor = to_rp5_color(_bgcolor)
      @bgcolor = $app.color(*_bgcolor)
      @_surface = $app.create_graphics(width, height)
      @queue = []
    end

    def width
      return @_surface.width
    end

    def height
      return @_surface.height
    end

    def bgcolor
      return to_dxr_color(@bgcolor)
    end

    def bgcolor=(color)
      color = to_rp5_color(color)
      @bgcolor = $app.color(*color)
    end

    def update
      @_surface.begin_draw()
      @_surface.background(@bgcolor)
      @queue.sort { |a, b| a[:z] <=> b[:z] }.each do |task|
        task[:proc].call
      end
      @queue.clear
      @_surface.end_draw()
    end

    def draw(x, y, image, z = 0)
      return if image.nil?
      draw_task = {
        :proc => lambda { @_surface.image(image._surface, x, y) },
        :z => z
      }
      @queue << draw_task
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
        @_surface.push_matrix
        @_surface.text_size(font.size)
        @_surface.text_font(font.native)
        # DXRubyでは文字の配置指定はできないため、都度text_alignを指定
        # せず固定で良いかもしれない
        @_surface.text_align(Processing::App::LEFT, Processing::App::TOP)
        @_surface.fill(color)
        string.lines.each.with_index do |line, i|
          line.chomp!
          if line.empty?
            next
          end
          @_surface.text(string, x, y)
        end
        @_surface.pop_matrix
      end

      draw_task = {
        :proc => proc,
        :z => hash[:z] || 0,
      }
      @queue << draw_task
    end

    def draw_tile(basex, basey, map, image_arr, startx, starty, sizex, sizey, z = 0)
      image_arr = image_arr.flatten
      first_img = image_arr[0]
      w, h = first_img.width, first_img.height
      startx_mod_w = startx % w
      starty_mod_h = starty % h

      from_i = starty_mod_h < 0 ? -1 : 0
      to_i   = sizey + (starty_mod_h <= 0 ?  0 : 1)
      from_j = startx_mod_w < 0 ? -1 : 0
      to_j   = sizex + (startx_mod_w <= 0 ?  0 : 1)

      y = basey - (starty_mod_h < 0 ? h + starty_mod_h : starty_mod_h)
      init_x = basex - (startx_mod_w < 0 ? w + startx_mod_w : startx_mod_w)

      (from_i..to_i).each do |i|
        if (i + starty / h) < 0
          my = (((i + starty / h) % map.size) + map.size) % map.size
        else
          my = (i + starty / h) % map.size
        end
        map_row = map[my]

        x = init_x
        (from_j..to_j).each do |j|
          if (j + startx / w) < 0
            mx = (((j + startx / w) % map_row.size) + map_row.size) % map_row.size
          else
            mx = (j + startx / w) % map_row.size
          end
          idx = map_row[mx]

          map_img = image_arr[idx]
          self.draw(x, y, map_img, z)

          x += w
        end
        y += h
      end
    end

    alias_method :drawFont, :draw_font
    alias_method :drawTile, :draw_tile

    private

    def to_dxr_color(c)
      dxr_c = [c >> 16 & 0xFF, c >> 8 & 0xFF, c & 0xFF]
      if @_surface.format == Processing::App::ARGB
        return dxr_c.unshift(c >> 24 & 0xFF)
      else
        return dxr_c
      end
    end

    def to_rp5_color(color)
      if color.size > 3
        color = color.dup
        color.push(color.shift)
      end
      return color
    end
  end
end
