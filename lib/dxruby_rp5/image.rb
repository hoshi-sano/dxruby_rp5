# -*- coding: utf-8 -*-
module DXRubyRP5
  class Image
    attr_reader :_surface

    def self.load(filename, x = nil, y = nil, width = nil, height = nil)
      image = self.new(0, 0)
      surface = $app.load_image(filename)
      surface.format = Processing::App::ARGB
      image.instance_variable_set('@_surface', surface)
      return image
    end

    def self.load_tiles(filename, xcount, ycount, switch = true)
      surface = $app.load_image(filename)
      width = surface.width / xcount
      height = surface.height / ycount
      images = []
      ycount.times do |y|
        xcount.times do |x|
          image = new(0, 0)
          s = $app.create_image(width, height, Processing::App::ARGB)
          s.copy(surface, x * width, y * height, width, height,
                                  0,          0, width, height)
          image.instance_variable_set('@_surface', s)
          images << image
        end
      end
      return images
    end

    def initialize(width, height, _color = [0, 0, 0, 0])
      _color = to_rp5_color(_color)
      @color = $app.color(*_color)

      if width == 0 && height == 0
        return
      end

      @_surface = $app.create_image(width, height, Processing::App::ARGB)
      @_surface.pixels.each_with_index do |px, i|
        @_surface.pixels[i] = @color
      end
    end

    def width
      return @_surface.width
    end

    def height
      return @_surface.height
    end

    def [](x, y)
      px = @_surface.get(x, y)
      _color = [red(px).to_i, green(px).to_i, blue(px).to_i]
      if @_surface.format == Processing::App::ARGB
        _color.unshift(alpha(px).to_i)
      end
      return _color
    end

    def []=(x, y, _color)
      _color = to_rp5_color(_color)
      return @_surface.set(x, y, $app.color(*_color))
    end

    def set_color_key(_color)
      r, g, b = *_color[-3..-1]
      alpha = $app.color(r, g, b, 0)

      @_surface.pixels.each_with_index do |px, i|
        if (r == red(px).to_i) &&
            (g == green(px).to_i) &&
            (b == blue(px).to_i)
          @_surface.pixels[i] = alpha
        end
      end
    end

    def compare(x, y, _color)
      _color = to_rp5_color(_color)
      max = _color.size - 1
      px = @_surface.get(x, y)
      c = [red(px),  green(px),
           blue(px), alpha(px)].map(&:to_i)
      return c[0..max] == _color
    end

    def line(x1, y1, x2, y2, _color)
      _color = to_rp5_color(_color)
      draw_on_image(_color, false) do |pg|
        pg.line(x1, y1, x2, y2)
      end
    end

    def box(x1, y1, x2, y2, _color)
      rect(x1, y1, x2, y2, _color)
    end

    def box_fill(x1, y1, x2, y2, _color)
      rect(x1, y1, x2, y2, _color, true)
    end

    def circle(x, y, r, _color)
      ellipse(x, y, 2*r, 2*r, _color)
    end

    def circle_fill(x, y, r, _color)
      ellipse(x, y, 2*r, 2*r, _color, true)
    end

    def triangle(x1, y1, x2, y2, x3, y3, _color)
      _triangle(x1, y1, x2, y2, x3, y3, _color)
    end

    def triangle_fill(x1, y1, x2, y2, x3, y3, _color)
      _triangle(x1, y1, x2, y2, x3, y3, _color, true)
    end

    def slice(x, y, width, height)
      image = self.class.new(0, 0)
      s = $app.create_image(width, height, Processing::App::ARGB)
      s.copy(@_surface, x, y, width, height,
                        0, 0, width, height)
      image.instance_variable_set('@_surface', s)
      return image
    end

    def slice_tiles(xcount, ycount, switch = true)
      width = @_surface.width / xcount
      height = @_surface.height / ycount
      images = []
      ycount.times do |y|
        xcount.times do |x|
          images << slice(x * width, y * height, width, height)
        end
      end
      return images
    end

    class << self
      alias_method :loadTiles, :load_tiles
      alias_method :load_to_array, :load_tiles
      alias_method :loadToArray, :load_to_array
    end
    alias_method :boxFill, :box_fill
    alias_method :circleFill, :circle_fill
    alias_method :triangleFill, :triangle_fill
    alias_method :setColorKey, :set_color_key
    alias_method :sliceTiles, :slice_tiles
    alias_method :slice_to_array, :slice_tiles
    alias_method :sliceToArray, :slice_to_array

    private

    def to_rp5_color(_color)
      if _color.size > 3
        _color = _color.dup
        _color.push(_color.shift)
      end
      return _color
    end

    def alpha(rgb)
      return rgb >> 24 & 0xFF
    end

    def red(rgb)
      return rgb >> 16 & 0xFF
    end

    def green(rgb)
      return rgb >> 8 & 0xFF
    end

    def blue(rgb)
      return rgb & 0xFF
    end

    # TODO: simplify
    def draw_on_image(rp5_color, fill)
      w, h = @_surface.width, @_surface.height
      pg = $app.create_graphics(w, h)
      pg.begin_draw
      pg.image(@_surface, 0, 0)
      pg.push_matrix
      pg.stroke(*rp5_color)
      fill ? pg.fill(*rp5_color) : pg.no_fill
      yield(pg)
      pg.pop_matrix
      pg.end_draw
      @_surface.copy(pg, 0, 0, w, h, 0, 0, w, h)
      return self
    end

    def rect(x1, y1, x2, y2, _color, fill=false)
      _color = to_rp5_color(_color)
      draw_on_image(_color, fill) do |pg|
        pg.rect(x1, y1, x2, y2)
      end
    end

    def ellipse(x, y, width, heigth, _color, fill=false)
      _color = to_rp5_color(_color)
      draw_on_image(_color, fill) do |pg|
        pg.ellipse(x, y, width, height)
      end
    end

    def _triangle(x1, y1, x2, y2, x3, y3, _color, fill=false)
      _color = to_rp5_color(_color)
      draw_on_image(_color, fill) do |pg|
        pg.triangle(x1, y1, x2, y2, x3, y3)
      end
    end
  end
end
