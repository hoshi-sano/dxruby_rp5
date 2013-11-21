# -*- coding: utf-8 -*-
require 'spec_helper'

describe DXRubyRP5::Sound, '音を表すクラス' do
  describe '.new' do
    shared_context '.new' do
      subject { described_class.new(fixture_path(filename)) }

      it '呼び出すことができる' do
        subject
      end
    end

    context 'WAVE形式のファイルの場合' do
      let(:filename) { 'sound.wav' }

      include_context '.new'
    end

    # context 'MIDI形式のファイルの場合' do
    #   let(:filename) { 'bgm.mid' }
    #
    #   include_context '.new'
    # end
  end

  describe '#play' do
    context 'WAVE形式のファイルの場合' do
      let(:path) { fixture_path('sound.wav') }
      let(:sound) { described_class.new(path) }

      subject { sound.play }

      it '呼び出すことができる' do
        subject
      end
    end

    # context 'MIDI形式のファイルの場合' do
    #   let(:path) { fixture_path('bgm.mid') }
    #   let(:sound) { DXRubySDL::Sound.new(path) }
    #
    #   subject { sound.play }
    #
    #   it '呼び出すことができる' do
    #     subject
    #   end
    # end
  end
end
