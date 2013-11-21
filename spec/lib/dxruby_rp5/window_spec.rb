# -*- coding: utf-8 -*-
require 'spec_helper'

describe DXRubyRP5::Window do
  describe '.loop',
  'ブロック内を実行する #draw メソッドをスケッチに定義する' do
    def run_sketch(app_name)
      Sketch.new
      args = ['--location=0, 0', app_name]
      PApplet.run_sketch(args, $app)
      while true
        $app.draw
      end
    end

    context 'Sketch#draw が実行される毎に TTL を減算し、' \
            'TTL が 0 以下になったら exit する loop を定義した場合' do
      subject do
        ttl = 5
        described_class.loop do
          ttl -= 1
          exit if ttl < 0
        end

        expect { run_sketch('test_app') }.to raise_error(SystemExit)

        $app.exit
        return ttl
      end

      it '終了時の TTL は -1 となる' do
        should eq(-1)
      end
    end
  end
end
