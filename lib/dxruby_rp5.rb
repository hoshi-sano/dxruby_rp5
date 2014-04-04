# -*- coding: utf-8 -*-
unless defined? DXRUBY_RP5_ROOT
  $LOAD_PATH << File.expand_path(File.dirname(__FILE__))
  DXRUBY_RP5_ROOT = File.expand_path(File.dirname(__FILE__) + "/../")
end

require 'ruby-processing'

module DXRubyRP5
  %w[
    K_0
    K_1
    K_2
    K_3
    K_4
    K_5
    K_6
    K_7
    K_8
    K_9
    K_A
    K_ABNT_C1
    K_ABNT_C2
    K_ADD
    K_APOSTROPHE
    K_APPS
    K_AT
    K_AX
    K_B
    K_BACK
    K_BACKSLASH
    K_BACKSPACE
    K_C
    K_CALCULATOR
    K_CAPITAL
    K_CAPSLOCK
    K_COLON
    K_COMMA
    K_CONVERT
    K_D
    K_DECIMAL
    K_DELETE
    K_DIVIDE
    K_DOWN
    K_DOWNARROW
    K_E
    K_END
    K_EQUALS
    K_ESCAPE
    K_F
    K_F1
    K_F10
    K_F11
    K_F12
    K_F13
    K_F14
    K_F15
    K_F2
    K_F3
    K_F4
    K_F5
    K_F6
    K_F7
    K_F8
    K_F9
    K_G
    K_GRAVE
    K_H
    K_HOME
    K_I
    K_INSERT
    K_J
    K_K
    K_KANA
    K_KANJI
    K_L
    K_LALT
    K_LBRACKET
    K_LCONTROL
    K_LEFT
    K_LEFTARROW
    K_LMENU
    K_LSHIFT
    K_LWIN
    K_M
    K_MAIL
    K_MEDIASELECT
    K_MEDIASTOP
    K_MINUS
    K_MULTIPLY
    K_MUTE
    K_MYCOMPUTER
    K_N
    K_NEXT
    K_NEXTTRACK
    K_NOCONVERT
    K_NUMLOCK
    K_NUMPAD0
    K_NUMPAD1
    K_NUMPAD2
    K_NUMPAD3
    K_NUMPAD4
    K_NUMPAD5
    K_NUMPAD6
    K_NUMPAD7
    K_NUMPAD8
    K_NUMPAD9
    K_NUMPADCOMMA
    K_NUMPADENTER
    K_NUMPADEQUALS
    K_NUMPADMINUS
    K_NUMPADPERIOD
    K_NUMPADPLUS
    K_NUMPADSLASH
    K_NUMPADSTAR
    K_O
    K_OEM_102
    K_P
    K_PAUSE
    K_PERIOD
    K_PGDN
    K_PGUP
    K_PLAYPAUSE
    K_POWER
    K_PREVTRACK
    K_PRIOR
    K_Q
    K_R
    K_RALT
    K_RBRACKET
    K_RCONTROL
    K_RETURN
    K_RIGHT
    K_RIGHTARROW
    K_RMENU
    K_RSHIFT
    K_RWIN
    K_S
    K_SCROLL
    K_SEMICOLON
    K_SLASH
    K_SLEEP
    K_SPACE
    K_STOP
    K_SUBTRACT
    K_SYSRQ
    K_T
    K_TAB
    K_U
    K_UNDERLINE
    K_UNLABELED
    K_UP
    K_UPARROW
    K_V
    K_VOLUMEDOWN
    K_VOLUMEUP
    K_W
    K_WAKE
    K_WEBBACK
    K_WEBFAVORITES
    K_WEBFORWARD
    K_WEBHOME
    K_WEBREFRESH
    K_WEBSEARCH
    K_WEBSTOP
    K_X
    K_Y
    K_YEN
    K_Z
  ].each.with_index do |k_name, i|
    const_set(k_name.to_sym, i)
  end

  %w[
    P_LEFT
    P_RIGHT
    P_UP
    P_DOWN
    P_BUTTON0
    P_BUTTON1
    P_BUTTON2
    P_BUTTON3
    P_BUTTON4
    P_BUTTON5
    P_BUTTON6
    P_BUTTON7
    P_BUTTON8
    P_BUTTON9
    P_BUTTON10
    P_BUTTON11
    P_BUTTON12
    P_BUTTON13
    P_BUTTON14
    P_BUTTON15
    P_D_LEFT
    P_D_RIGHT
    P_D_UP
    P_D_DOWN
    P_R_LEFT
    P_R_RIGHT
    P_R_UP
    P_R_DOWN
  ].each.with_index do |name, i|
    const_set(name.to_sym, i)
  end

  %w[
    P_L_LEFT
    P_L_RIGHT
    P_L_UP
    P_L_DOWN
  ].each.with_index do |name, i|
    const_set(name.to_sym, i)
  end

  %w[
    M_LBUTTON
    M_RBUTTON
    M_MBUTTON
  ].each.with_index do |name, i|
    const_set(name.to_sym, i)
  end

  %w[
    WAVE_SIN
    WAVE_SAW
    WAVE_TRI
    WAVE_RECT
  ].each.with_index do |name, i|
    const_set(name.to_sym, i)
  end
end

require_relative 'dxruby_rp5/version'
require_relative 'dxruby_rp5/runner'

if RUBY_ENGINE == "jruby"
  require_relative 'dxruby_rp5/window'
  require_relative 'dxruby_rp5/image'
  require_relative 'dxruby_rp5/input'
  require_relative 'dxruby_rp5/font'
  require_relative 'dxruby_rp5/sprite'
  require_relative 'dxruby_rp5/sound'
  require_relative 'dxruby_rp5/sound_effect'
  require_relative 'dxruby_rp5/render_target'

  Processing::App.sketch_class.load_library :minim
  Processing::App.sketch_class.class_eval { import 'ddf.minim' }
end
