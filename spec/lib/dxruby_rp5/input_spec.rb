# -*- coding: utf-8 -*-
require 'spec_helper'

describe DXRubyRP5::Input,
         'キーボード・ゲームパッド・マウスの入力を扱うモジュール' do

  lowers = ('a'..'z').to_a
  uppers = lowers.map(&:upcase)
  KEY_KEYCODE_MAP = {
    :a_to_z => lowers.map {|c| [c, "K_#{uppers.shift}".to_sym] },
    :symbols => [
                 ['\'', :K_APOSTROPHE],
                 ['@',  :K_AT],
                 ['\\', :K_BACKSLASH],
                 [':',  :K_COLON],
                 [',',  :K_COMMA],
                 ['=',  :K_EQUALS],
                 ['[',  :K_LBRACKET],
                 [']',  :K_RBRACKET],
                 ['-',  :K_MINUS],
                 ['*',  :K_MULTIPLY],
                 ['.',  :K_PERIOD],
                 [';',  :K_SEMICOLON],
                 ['/',  :K_SLASH],
                 ['_',  :K_UNDERLINE],
                ],
    :p5_constans => [
                     [:LEFT, :K_LEFT],
                     [:RIGHT, :K_RIGHT],
                     [:UP, :K_UP],
                     [:DOWN, :K_DOWN],
                     [:SHIFT, :K_LSHIFT],
                     [:ALT, :K_LALT],
                     [:CONTROL, :K_LCONTROL],
                    ],
  }

  def get_key_event_config(key, action = true)
    if key.kind_of?(String)
      key_code = 0
      key_char = key.bytes.first
    elsif Processing::App.constants.include?(key)
      key_code = Processing::App.const_get(key)
      key_char = 65535
    end
    key_action =
      case action
      when :press
        :KEY_PRESSED
      when :type
        :KEY_TYPED
      when :release
        :KEY_RELEASED
      end
    id = Java::JavaAwtEvent::KeyEvent.const_get(key_action)

    return id, key_code, key_char
  end

  def create_java_key_event(id, key_code, key_char)
    args = [
            $app,                 # component
            id,
            Time.now.to_i * 1000, # when
            0,                    # modifiers
            key_code,
            key_char
           ]
    return Java::JavaAwtEvent::KeyEvent.new(*args)
  end

  def create_processing_key_event(key, action)
    jke = create_java_key_event(*get_key_event_config(key, action))
    pe_action =
      case jke.get_id
      when Java::JavaAwtEvent::KeyEvent::KEY_PRESSED
        Java::ProcessingEvent::KeyEvent::PRESS
      when Java::JavaAwtEvent::KeyEvent::KEY_RELEASED
        Java::ProcessingEvent::KeyEvent::RELEASE
      when Java::JavaAwtEvent::KeyEvent::KEY_TYPED
        Java::ProcessingEvent::KeyEvent::TYPE
      end
    # TODO: support modifiers
    return Java::ProcessingEvent::KeyEvent.new(jke, jke.get_when, pe_action, 0,
                                               jke.get_key_char, jke.get_key_code)
  end

  def push_key_press_event(key)
    pke = create_processing_key_event(key, :press)
    $app.post_event(pke)
  end

  def push_key_type_event(key)
    # 'type' action is not supported now
    # pke = create_processing_key_event(key, :type)
    pke = create_processing_key_event(key, :press)
    $app.post_event(pke)
  end

  def push_key_code_to_pressed_keys(key)
    pressed_keys = described_class.instance_variable_get(:@pressed_keys) || []
    table = Hash[KEY_KEYCODE_MAP.values.flatten(1)]
    pressed_keys << DXRubyRP5.const_get(table[key])
    described_class.instance_variable_set(:@pressed_keys, pressed_keys)
  end

  def push_key_code_to_pushed_keys(key)
    pushed_keys = described_class.instance_variable_get(:@pushed_keys) || []
    table = Hash[KEY_KEYCODE_MAP.values.flatten(1)]
    pushed_keys << DXRubyRP5.const_get(table[key])
    described_class.instance_variable_set(:@pushed_keys, pushed_keys)
  end

  def clean_described_class_instance_variables
    described_class.instance_variables.each do |sym|
      described_class.instance_variable_set(sym, nil)
    end
  end

  before(:each) do
    # to reset key events
    Sketch.new
  end

  after(:each) do
    clean_described_class_instance_variables
  end

  shared_context '.set_repeat' do
    let(:wait) { 0 }
    let(:repeat) { 0 }

    before(:each) {described_class.setRepeat(wait, repeat)}

    subject do
      [
       :@repeat_wait,
       :@repeat_interval,
      ].map {|sym| described_class.instance_variable_get(sym) }
    end

    context 'wait = 0, repeat = 0 で設定した場合' do
      it { should eq([nil, nil]) }
    end

    context 'wait = 1, repeat = 1 で設定した場合' do
      let(:wait) { 1 }
      let(:repeat) { 1 }

      it { should eq([wait, repeat]) }
    end
  end

  describe '.set_repeat', 'キーリピートを設定する' do

    include_context '.set_repeat'

    describe 'alias' do
      describe '.setRepeat' do
        it_behaves_like '.set_repeat' do
        end
      end
    end
  end

  shared_context 'push key_codes to pressed_keys' do
    let(:_keys) { [] }

    before { _keys.each { |key| push_key_code_to_pressed_keys(key) } }
  end

  shared_context 'push key_codes to pushed_keys' do
    let(:_keys) { [] }

    before { _keys.each { |key| push_key_code_to_pushed_keys(key) } }
  end

  shared_context 'push key_press events' do
    let(:_keys) { [] }

    before { _keys.each { |key| push_key_press_event(key) } }
  end

  shared_context 'push key_type events' do
    let(:_keys) { [] }

    before { _keys.each { |key| push_key_type_event(key) } }
  end

  describe '.x' do
    subject { described_class.x }

    context 'Processing::KEY_METHODS を使う場合' do
      include_context 'push key_codes to pressed_keys'

      context '左カーソルが押されている場合' do
        let(:_keys) { [:LEFT] }

        it { should eq(-1) }
      end

      context '右カーソルが押されている場合' do
        let(:_keys) { [:RIGHT] }

        it { should eq(1) }
      end

      context '左・右の順で両カーソルが押されている場合' do
        let(:_keys) { [:LEFT, :RIGHT] }

        it { should eq(0) }
      end

      context '右・左の順で両カーソルが押されている場合' do
        let(:_keys) { [:RIGHT, :LEFT] }

        it { should eq(0) }
      end

      context '左・右カーソルのどちらも押されていない場合' do
        it { should eq(0) }
      end
    end

    context 'Processing::KEY_METHODS を使わない場合' do
      include_context 'push key_press events'

      context '左カーソルが押されている場合' do
        let(:_keys) { [:LEFT] }

        it { should eq(-1) }
      end

      context '右カーソルが押されている場合' do
        let(:_keys) { [:RIGHT] }

        it { should eq(1) }
      end

      context '左・右の順で両カーソルが押されている場合' do
        let(:_keys) { [:LEFT, :RIGHT] }

        it { should eq(1) }
      end

      context '右・左の順で両カーソルが押されている場合' do
        let(:_keys) { [:RIGHT, :LEFT] }

        it { should eq(-1) }
      end

      context '左・右カーソルのどちらも押されていない場合' do
        it { should eq(0) }
      end
    end
  end

  describe '.y' do
    subject { described_class.y }

    context 'Processing::KEY_METHODS を使う場合' do
      include_context 'push key_codes to pressed_keys'

      context '上カーソルが押されている場合' do
        let(:_keys) { [:UP] }

        it { should eq(-1) }
      end

      context '下カーソルが押されている場合' do
        let(:_keys) { [:DOWN] }

        it { should eq(1) }
      end

      context '上・下の順で両カーソルが押されている場合' do
        let(:_keys) { [:UP, :DOWN] }

        it { should eq(0) }
      end

      context '下・上の順で両カーソルが押されている場合' do
        let(:_keys) { [:DOWN, :UP] }

        it { should eq(0) }
      end

      context '上・下カーソルのどちらも押されていない場合' do
        it { should eq(0) }
      end
    end

    context 'Processing::KEY_METHODS を使わない場合' do
      include_context 'push key_press events'

      context '上カーソルが押されている場合' do
        let(:_keys) { [:UP] }

        it { should eq(-1) }
      end

      context '下カーソルが押されている場合' do
        let(:_keys) { [:DOWN] }

        it { should eq(1) }
      end

      context '上・下の順で両カーソルが押されている場合' do
        let(:_keys) { [:UP, :DOWN] }

        it { should eq(1) }
      end

      context '下・上の順で両カーソルが押されている場合' do
        let(:_keys) { [:DOWN, :UP] }

        it { should eq(-1) }
      end

      context '上・下カーソルのどちらも押されていない場合' do
        it { should eq(0) }
      end
    end
  end

  shared_context '.key_down?' do

    KEY_KEYCODE_MAP.values.flatten(1).each do |k, kc|
      context "#{k}キーが押されている場合" do
        let(:_keys) { [k] }
        let(:key_code) { DXRubyRP5.const_get(kc) }

        it { should be_true }
      end
    end
  end

  describe '.key_down?' do
    subject { described_class.key_down?(key_code) }

    context 'Processing::KEY_METHODS を使う場合' do
      include_context 'push key_codes to pressed_keys'
      include_context '.key_down?'
    end

    context 'Processing::KEY_METHODS を使わない場合' do
      include_context 'push key_press events'
      include_context '.key_down?'
    end

    describe 'alias' do
      describe '.keyDown?' do

        context 'Processing::KEY_METHODS を使う場合' do
          include_context 'push key_codes to pressed_keys'

          it_behaves_like '.key_down?' do
            subject { described_class.keyDown?(key_code) }
          end
        end

        context 'Processing::KEY_METHODS を使わない場合' do
          include_context 'push key_press events'

          it_behaves_like '.key_down?' do
            subject { described_class.keyDown?(key_code) }
          end
        end
      end
    end
  end

  describe '.key_push?' do
    subject { described_class.key_push?(key_code) }

    context 'Processing::KEY_METHODS を使う場合' do
      include_context 'push key_codes to pushed_keys'
      include_context '.key_down?'
    end

    context 'Processing::KEY_METHODS を使わない場合' do
      include_context 'push key_press events'
      include_context '.key_down?'
    end

    describe 'alias' do
      describe '.keyPush?' do

        context 'Processing::KEY_METHODS を使う場合' do
          include_context 'push key_codes to pushed_keys'

          it_behaves_like '.key_down?' do
            subject { described_class.keyPush?(key_code) }
          end
        end

        context 'Processing::KEY_METHODS を使わない場合' do
          include_context 'push key_press events'

          it_behaves_like '.key_down?' do
            subject { described_class.keyPush?(key_code) }
          end
        end
      end
    end
  end
end
