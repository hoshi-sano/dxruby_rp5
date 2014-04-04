# -*- coding: utf-8 -*-
module DXRubyRP5
  class Sound
    class << self
      private

      def minim
        @minim ||= Java::DdfMinim::Minim.new($app)
      end
    end

    def initialize(filename)
      @_sound = self.class.send(:minim).load_file(filename)
    end

    def play
      # TODO: loop
      @_sound.play
      @_sound.rewind
      return self
    end

    def set_volume(volume, time = 0)
    end
  end
end
