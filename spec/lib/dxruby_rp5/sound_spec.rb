# -*- coding: utf-8 -*-
require 'spec_helper'

describe DXRubyRP5::Sound, '音を表すクラス' do
  describe '.new' do
    shared_context '.new' do
      before(:each) do
        m = Java::DdfMinim::Minim.new($app)
        Java::DdfMinim::Minim.should_receive(:new).with($app).once.and_return(m)
      end

      subject { described_class.new(path) }

      it '呼び出すことができる' do
        expect { subject }.to_not raise_error
      end
    end

    context 'WAVE形式のファイルの場合' do
      let(:path) { fixture_path('sound.wav') }

      include_context '.new'
    end

    # context 'MIDI形式のファイルの場合' do
    #   let(:filename) { 'bgm.mid' }
    #
    #   include_context '.new'
    # end
  end

  describe '#play' do
    shared_context '#play' do
      let(:sound) do
        sound = described_class.new(path)
        audio_player = sound.instance_variable_get(:@_sound)
        audio_player.should_receive(:play).once
        audio_player.should_receive(:rewind).once
        sound
      end

      subject { sound.play }

      it { should eq(sound) }
    end

    context 'WAVE形式のファイルの場合' do
      let(:path) { fixture_path('sound.wav') }
    end

    # context 'MIDI形式のファイルの場合' do
    #   let(:path) { fixture_path('bgm.mid') }
    # end
  end
end
