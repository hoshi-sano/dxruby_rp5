# -*- coding: utf-8 -*-
require 'spec_helper'

describe DXRubyRP5::Font, 'フォントを表すクラス' do
  before(:all) do
    Sketch.new
  end

  describe '.new' do
    given = 32
    context "大きさ(#{given.inspect})を指定した場合" do
      subject { described_class.new(given) }

      its(:size) { should eq(given) }
    end
  end
end
