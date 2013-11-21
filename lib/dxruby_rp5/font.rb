# -*- coding: utf-8 -*-
module DXRubyRP5
  class Font
    attr_reader :size
    attr_reader :native

    @font_cache = {}

    def initialize(size, fontname = '', hash = {})
      @size = size
      # TODO: fontname の変換
      fontname = "IPAGothic" # あとで消す
      @native = $app.create_font(fontname, @size)
    end

    def get_width(string)
      # TODO:
      $app.text_size(@size)
      return $app.text_width(string);
    end

    alias_method :getWidth, :get_width

    private
  end
end
