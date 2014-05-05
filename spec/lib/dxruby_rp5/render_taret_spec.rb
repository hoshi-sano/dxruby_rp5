# -*- coding: utf-8 -*-
require 'spec_helper'

describe DXRubyRP5::RenderTarget do
  let(:width) { 100 }
  let(:height) { 60 }
  let(:format) { Processing::App::ARGB }

  before(:each) do
    Sketch.new
    # Sketch#run しないと Sketch#create_graphics が Error になるので、
    # dummy を使用する
    surface = double(:width => width, :height => height, :format => format)
    $app.stub(:create_graphics).and_return(surface)
  end

  shared_context '.new with color' do
    let(:color) { [0, 0, 0, 0] }

    subject { described_class.new(width, height, color) }
  end

  describe '.new' do
    context '幅と高さを指定した場合' do
      subject { described_class.new(width, height) }

      it { should be_an_instance_of(described_class) }
    end

    context '幅と高さと色(RGB)を指定した場合' do
      include_context '.new with color'

      let(:format) { Processing::App::RGB }
      let(:color) { [10, 20, 30] }

      it { should be_an_instance_of(described_class) }
    end

    context '幅と高さと色(RGB)を指定した場合' do
      include_context '.new with color'

      let(:format) { Processing::App::ARGB }
      let(:color) { [0, 10, 20, 30] }

      include_context '.new with color'
      it { should be_an_instance_of(described_class) }
    end
  end

  describe '#width' do
    subject { described_class.new(width, height) }

    its(:width) { should eq(width) }
  end

  describe '#height' do
    subject { described_class.new(width, height) }

    its(:height) { should eq(height) }
  end

  describe '#bgcolor' do
    context '色の指定をしない場合' do
      subject { described_class.new(width, height) }

      its(:bgcolor) { should eq([0, 255, 255, 255]) }
    end

    context '色の指定を RGB でする場合' do
      include_context '.new with color'

      let(:format) { Processing::App::RGB }
      let(:color) { [10, 20, 30] }

      its(:bgcolor) { should eq([10, 20, 30]) }
    end

    context '色の指定を ARGB でする場合' do
      include_context '.new with color'

      let(:format) { Processing::App::ARGB }
      let(:color) { [0, 10, 20, 30] }

      its(:bgcolor) { should eq([0, 10, 20, 30]) }
    end
  end

  describe '#draw' do
    let(:image) { DXRubyRP5::Image.load(fixture_path('image.png')) }
    let(:rt) { described_class.new(width, height) }

    context 'Image オブジェクトを一つ渡した場合の描画用の queue' do
      before { rt.draw(10, 10, image) }

      subject { rt.instance_variable_get(:@queue) }

      its(:size) { should eq(1) }

      context 'queue の中身の proc と z' do
        it { subject.first[:proc].should be_instance_of(Proc) }
        it { subject.first[:z].should eq(0) }
      end
    end
  end
end
