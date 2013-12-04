# -*- coding: utf-8 -*-
module DXRubyRP5
  class Font
    attr_reader :size
    attr_reader :native

    @font_cache = {}

    def initialize(size, fontname = '', hash = {})
      @size = size
      # TODO: use fontname
      gothics = PFont.list.grep(/gothic/i)
      if gothics.any?
        ipa_gothics = gothics.grep(/ipa/i)
        if ipa_gothics.any?
          fontname = ipa_gothics.first
        else
          fontname = gothics.first
        end
      else
        fontname = PFont.list.first
      end
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
