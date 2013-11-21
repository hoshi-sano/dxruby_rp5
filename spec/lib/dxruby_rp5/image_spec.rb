# -*- coding: utf-8 -*-
# Includes and uses as reference 'dxruby_sdl'
# Copyright (c) 2013 TAKAO Kouji
# Released under the MIT License.
# see https://github.com/takaokouji/dxruby_sdl

require 'spec_helper'

describe DXRubyRP5::Image, '画像を表すクラス' do

  before(:all) { Sketch.new }

  let(:image) { described_class.new(640, 480) }

  describe '.new' do
    context '幅と高さを指定した場合' do
      subject { image }

      its(:width) { should eq(640) }
      its(:height) { should eq(480) }
    end
  end

  describe '.load' do
    subject { described_class.load(fixture_path(filename)) }

    context 'PNG形式のファイル(100x60)の場合' do
      let(:filename) { 'image.png' }

      its(:width) { should eq(100) }
      its(:height) { should eq(60) }
    end

    context 'JPG形式のファイル(100x60)の場合' do
      let(:filename) { 'image.jpg' }

      its(:width) { should eq(100) }
      its(:height) { should eq(60) }
    end
  end

  shared_context '.load_tiles' do
    context '画像の幅と高さが割り切れる(100x60、xcountが2、ycountが4)場合' do
      let(:xcount) { 2 }
      let(:ycount) { 4 }

      its(:length) { should eq(xcount * ycount) }

      it '各オブジェクトの幅はxcount(2)等分したものである' do
        subject.each do |image|
          expect(image.width).to eq(100 / xcount)
        end
      end

      it '各オブジェクトの高さはycount(4)等分したものである' do
        subject.each do |image|
          expect(image.height).to eq(60 / ycount)
        end
      end
    end
  end

  describe '.load_tiles',
           '画像を読み込み、横・縦がそれぞれxcount個、' \
           'ycount個であると仮定して自動で分割し、' \
           '左上から右に向かう順序でImageオブジェクトの配列を生成して返す' do
    subject {
      described_class.load_tiles(fixture_path('image.png'), xcount, ycount)
    }

    include_context '.load_tiles'

    describe 'alias' do
      describe '.loadTiles' do
        it_behaves_like '.load_tiles' do
          subject {
            described_class.loadTiles(fixture_path('image.png'),
                                       xcount, ycount)
          }
        end
      end

      describe '.load_to_array' do
        it_behaves_like '.load_tiles' do
          subject {
            described_class.load_to_array(fixture_path('image.png'),
                                           xcount, ycount)
          }
        end
      end

      describe '.loadToArray' do
        it_behaves_like '.load_tiles' do
          subject {
            described_class.loadToArray(fixture_path('image.png'),
                                         xcount, ycount)
          }
        end
      end
    end
  end

  describe '#compare' do
    let(:image) { described_class.load(fixture_path('image.png')) }

    subject { image.compare(0, 0, color) }

    context '指定した座標の色が等しい場合' do
    let(:color) { [255, 0, 0] }

      it { should be_true }
    end

    context '指定した座標の色が等しくない場合' do
    let(:color) { [0, 255, 0] }

      it { should be_false }
    end
  end

  describe '#slice' do
    let(:image) { described_class.load(fixture_path('image.png')) }

    subject { image.slice(10, 10, 20, 40) }

    its(:width) { should eq(20) }
    its(:height) { should eq(40) }
    it { should be_instance_of(described_class) }
    it '各ピクセルデータが正しい' do
      expect_image = $app.create_image(20, 40, Processing::App::ARGB)
      expect_image.copy(image._surface, 10, 10, 20, 40, 0, 0, 20, 40)

      # MEMO: 単純な subject._surface.pixels == expect_image.pixels と
      #       いう比較が不可能なため、ピクセル毎に比較する
      equality = true
      subject._surface.pixels.each_with_index do |px, i|
        equality &= (px == expect_image.pixels[i])
      end

      expect(equality).to be_true
    end
  end

  shared_context '#slice_tiles' do
    let(:image) { described_class.load(fixture_path('image.png')) }

    context '画像の幅と高さが割り切れる(100x60、xcountが2、ycountが4)場合' do
      let(:xcount) { 2 }
      let(:ycount) { 4 }

      its(:length) { should eq(xcount * ycount) }

      it '各オブジェクトの幅はxcount(2)等分したものである' do
        subject.each do |image|
          expect(image.width).to eq(100 / xcount)
        end
      end

      it '各オブジェクトの高さはycount(4)等分したものである' do
        subject.each do |image|
          expect(image.height).to eq(60 / ycount)
        end
      end
    end
  end

  describe '#slice_tiles',
           '自身の画像を横・縦がそれぞれxcount個、ycount個に分割し、' \
           '左上から右に向かう順序でImageオブジェクトの配列を生成して返す' do
    subject { image.slice_tiles(2, 4) }

    include_context '#slice_tiles'

    describe 'alias' do
      describe '.sliceTiles' do
        it_behaves_like '#slice_tiles' do
          subject { image.sliceTiles(xcount, ycount) }
        end
      end

      describe '.slice_to_array' do
        it_behaves_like '#slice_tiles' do
          subject { image.slice_to_array(xcount, ycount) }
        end
      end

      describe '.sliceToArray' do
        it_behaves_like '#slice_tiles' do
          subject { image.sliceToArray(xcount, ycount) }
        end
      end
    end
  end
end
