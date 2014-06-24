# -*- coding: utf-8 -*-
module DXRubyRP5
  module Input
    module_function

    def set_repeat(wait, interval)
      if wait == 0 && interval == 0
        @repeat_wait = nil
        @repeat_interval = nil
      else
        @repeat_wait = wait
        @repeat_interval = interval
      end
    end

    def x(pad_number = 0)
      res = 0

      if @pressed_keys
        cond = lambda { |key| @pressed_keys.include?(to_dxruby_key(key)) }
      else
        cond = lambda { |key| rp5_key_press?(key) }
      end
      pad_val = rp5_pad_slider_value(:x)

      if cond.call(Processing::App::LEFT) || pad_val < 0
        res -= 1
      end
      if cond.call(Processing::App::RIGHT) || pad_val > 0
        res += 1
      end
      return res
    end

    def y(pad_number = 0)
      res = 0

      if @pressed_keys
        cond = lambda { |key| @pressed_keys.include?(to_dxruby_key(key)) }
      else
        cond = lambda { |key| rp5_key_press?(key) }
      end
      pad_val = rp5_pad_slider_value(:y)

      if cond.call(Processing::App::UP) || pad_val < 0
        res -= 1
      end
      if cond.call(Processing::App::DOWN) || pad_val > 0
        res += 1
      end
      return res
    end

    def mouse_pos_x
      return $app.mouse_x
    end

    def mouse_pos_y
      return $app.mouse_y
    end

    def key_down?(key_code)
      if @pressed_keys
        return @pressed_keys.include?(key_code)
      else
        return rp5_key_press?(to_rp5_key(key_code))
      end
    end

    def key_push?(key_code)
      if @pushed_keys
        return @pushed_keys.include?(key_code)
      else
        return rp5_key_press?(to_rp5_key(key_code))
      end
    end

    def mouse_down?(button)
      if @pressed_mbuttons
        return @pressed_mbuttons.include?(button)
      else
        return rp5_mouse_down?(button)
      end
    end

    def mouse_push?(button)
      if @pushed_mbuttons
        return @pushed_mbuttons.include?(button)
      else
        return rp5_mouse_down?(button)
      end
    end

    # TODO: support pad_number
    def pad_down?(button_code, pad_number = 0)
      if button_code == P_BUTTON0 && key_down?(K_Z) ||
          button_code == P_BUTTON1 && key_down?(K_X) ||
          button_code == P_BUTTON2 && key_down?(K_C) ||
          button_code == P_LEFT && key_down?(K_LEFT) ||
          button_code == P_RIGHT && key_down?(K_RIGHT) ||
          button_code == P_UP && key_down?(K_UP) ||
          button_code == P_DOWN && key_down?(K_DOWN) ||
          rp5_pad_pressed?(button_code)
        return true
      end
      return false
    end

    # TODO: support pad_number
    def pad_push?(button_code, pad_number = 0)
      if button_code == P_BUTTON0 && key_push?(K_Z) ||
          button_code == P_BUTTON1 && key_push?(K_X) ||
          button_code == P_BUTTON2 && key_push?(K_C) ||
          button_code == P_LEFT && key_push?(K_LEFT) ||
          button_code == P_RIGHT && key_push?(K_RIGHT) ||
          button_code == P_UP && key_push?(K_UP) ||
          button_code == P_DOWN && key_push?(K_DOWN) ||
          rp5_pad_pushed?(button_code)
        return true
      end
      return false
    end

    class << self
      alias_method :setRepeat, :set_repeat
      alias_method :padDown?, :pad_down?
      alias_method :padPush?, :pad_push?
      alias_method :keyDown?, :key_down?
      alias_method :keyPush?, :key_push?
      alias_method :mouseDown?, :mouse_down?
      alias_method :mousePush?, :mouse_push?
      alias_method :mousePosX, :mouse_pos_x
      alias_method :mousePosY, :mouse_pos_y

      private

      RP5_KEY_TABLE = {}
      replace_table = {
        'APOSTROPHE' => "'",
        'AT' => '@',
        'BACKSPACE' => "\b",
        'BACKSLASH' => '\\',
        'CAPSLOCK' => 'CAPS_LOCK',
        'COLON' => ':',
        'COMMA' => ',',
        'EQUALS' => '=',
        'GRAVE' => 'BACK_QUOTE',
        'LALT' => 'ALT',
        'RALT' => 'ALT',
        'LBRACKET' => '[',
        'RBRACKET' => ']',
        'LCONTROL' => 'CONTROL',
        'RCONTROL' => 'CONTROL',
        'LSHIFT' => 'SHIFT',
        'RSHIFT' => 'SHIFT',
        'LWIN' => 'WINDOWS',
        'RWIN' => 'WINDOWS',
        'MINUS' => '-',
        'MULTIPLY' => '*',
        'NOCONVERT' => 'NONCONVERT',
        'NUMLOCK' => 'NUM_LOCK',
        'PERIOD' => '.',
        'RETURN' => "\n",
        'SCROLL' => 'SCROL_LOCK',
        'SEMICOLON' => ';',
        'SLASH' => '/',
        'SPACE' => ' ',
        'SUBTRACT' => '-',
        'TAB' => "\t",
        'UNDERLINE' => '_',
        'YEN' => '\\',
      }
      DXRubyRP5.constants.grep(/^K_/).each do |k|
        name = k.to_s.sub(/^K_/, '')
        if replace_table.key?(name)
          name = replace_table[name]
        end
        case name
        when /^(\S|\s|\\n|\\b|\\t)$/
          RP5_KEY_TABLE[DXRubyRP5.const_get(k)] = name.downcase
        else
          begin
            RP5_KEY_TABLE[DXRubyRP5.const_get(k)] =
              Java::JavaAwtEvent::KeyEvent.const_get("VK_#{name}".to_sym)
          rescue NameError
          end
        end
      end
      private_constant :RP5_KEY_TABLE

      DXRUBY_KEY_TABLE = RP5_KEY_TABLE.invert
      private_constant :DXRUBY_KEY_TABLE

      RP5_MBUTTON_TABLE = {
        M_LBUTTON => Processing::App::LEFT,
        M_MBUTTON => Processing::App::CENTER,
        M_RBUTTON => Processing::App::RIGHT,
      }
      private_constant :RP5_MBUTTON_TABLE

      DXRUBY_MBUTTON_TABLE = RP5_MBUTTON_TABLE.invert
      private_constant :DXRUBY_MBUTTON_TABLE

      JAVA_RP5_MBUTTON_TABLE = {
        Java::JavaAwtEvent::MouseEvent::BUTTON1 => Processing::App::LEFT,
        Java::JavaAwtEvent::MouseEvent::BUTTON2 => Processing::App::CENTER,
        Java::JavaAwtEvent::MouseEvent::BUTTON3 => Processing::App::RIGHT,
      }
      private_constant :JAVA_RP5_MBUTTON_TABLE

      # TODO: check dxruby supported keycode
      def rp5_key_press?(key)
        if $app.key_pressed?
          if $app.key == Processing::App::CODED
            return $app.key_code == key
          else
            return $app.key == key.chr
          end
        end
        return false
      end

      def rp5_mouse_down?(button)
        return if !$app.mouse_pressed?
        pressed_button = $app.mouse_button
        rp5_button = to_rp5_button(button)
        return rp5_button == pressed_button
      end

      def rp5_pad_slider_value(dir)
        return 0 if !@pad_sliders
        @pad_sliders[dir].value
      end

      def rp5_pad_pushed?(button_code)
        @pushed_pbuttons ||= []
        @pushed_pbuttons.include?(button_code)
      end

      def rp5_pad_pressed?(button_code)
        @pressed_pbuttons ||= []
        @pressed_pbuttons.include?(button_code)
      end

      def to_rp5_key(key_code)
        return RP5_KEY_TABLE[key_code]
      end

      def to_dxruby_key(key_code)
        return DXRUBY_KEY_TABLE[key_code]
      end

      def to_rp5_button(button)
        return RP5_MBUTTON_TABLE[button]
      end

      def to_dxruby_button(button)
        return DXRUBY_MBUTTON_TABLE[button]
      end

      def key_pressed(key, key_code)
        @pressed_keys ||= []
        if key == Processing::App::CODED
          dkey = to_dxruby_key(key_code)
        else
          dkey = to_dxruby_key(key.downcase)
        end
        return if @pressed_keys.include?(dkey)
        @pressed_keys << dkey
      end

      def key_pushed(key, key_code)
        @pushed_keys ||= []
        @checked_keys ||= []
        if key == Processing::App::CODED
          dkey = to_dxruby_key(key_code)
        else
          dkey = to_dxruby_key(key.downcase)
        end
        return if @checked_keys.include?(dkey)
        @pushed_keys << dkey
      end

      def key_released(key, key_code)
        return if @pressed_keys.nil?
        if key == Processing::App::CODED
          dkey = to_dxruby_key(key_code)
        else
          dkey = to_dxruby_key(key.downcase)
        end
        @pressed_keys.delete(dkey)
        @checked_keys.delete(dkey)
      end

      def mouse_pressed(button)
        @pressed_mbuttons ||= []
        rp5_button = JAVA_RP5_MBUTTON_TABLE[button]
        dbutton = to_dxruby_button(rp5_button)
        @pressed_mbuttons << dbutton
      end

      def mouse_pushed(button)
        @pushed_mbuttons ||= []
        @checked_mbuttons ||= []
        rp5_button = JAVA_RP5_MBUTTON_TABLE[button]
        dbutton = to_dxruby_button(rp5_button)
        return if @checked_mbuttons.include?(dbutton)
        @pushed_mbuttons << dbutton
      end

      def mouse_released(button)
        return if @pressed_mbuttons.nil?
        rp5_button = JAVA_RP5_MBUTTON_TABLE[button]
        dbutton = to_dxruby_button(rp5_button)
        @pressed_mbuttons.delete(dbutton)
        @checked_mbuttons.delete(dbutton)
      end

      def handle_key_events
        return if @pushed_keys.nil?
        @checked_keys |= @pushed_keys
        @pushed_keys.clear

        # for key repeat
        # TODO: use `wait`
        if @repeat_interval &&
            $app.frame_count % @repeat_interval == 0
          @pushed_keys |= @pressed_keys
          @checked_keys -= @pressed_keys
        end

        return if @pushed_mbuttons.nil?
        @checked_mbuttons = (@checked_mbuttons || @pushed_mbuttons)
        @pushed_mbuttons.clear
      end

      PSLIDER_DIRS = {
        x: [DXRubyRP5.const_get(:P_RIGHT),
            DXRubyRP5.const_get(:P_LEFT)],
        y: [DXRubyRP5.const_get(:P_DOWN),
            DXRubyRP5.const_get(:P_UP)],
      }

      def handle_pad_events
        return if @pad_sliders.nil? || @pad_buttons.nil?
        @pad_buttons.each do |key, button|
          if button.pressed
            pbutton_pressed(key)
          else
            pbutton_released(key)
          end
        end

        @pad_sliders.each do |symbol, slider|
          val = slider.value
          if val > 0
            pbutton_pressed(PSLIDER_DIRS[symbol][0])
          elsif val < 0
            pbutton_pressed(PSLIDER_DIRS[symbol][1])
          else
            pbutton_released(PSLIDER_DIRS[symbol][0])
            pbutton_released(PSLIDER_DIRS[symbol][1])
          end
        end
      end

      def pbutton_pressed(key)
        if @pushed_pbuttons.include?(key)
          @pushed_pbuttons.delete(key)
        else
          if !@pressed_pbuttons.include?(key)
            @pushed_pbuttons << key
            @pressed_pbuttons << key
          end
        end
      end

      def pbutton_released(key)
        @pushed_pbuttons.delete(key)
        @pressed_pbuttons.delete(key)
      end

      def load_gcp_native_libraries
        sketch_class = Processing::App.sketch_class
        lib_loader = sketch_class.class_variable_get(:@@library_loader)
        gcp_library_path =
          lib_loader.send(:get_library_directory_path, "GameControlPlus")
        java.lang.System.setProperty("java.library.path", gcp_library_path)
        loader = java.lang.Class.for_name("java.lang.ClassLoader")
        field = loader.get_declared_field("sys_paths")
        if field
          field.accessible = true
          loader = java.lang.Class.for_name("java.lang.System").get_class_loader
          field.set(loader, nil)
        end
      end

      def setup_pad_input(device)
        @pad_buttons = {}
        @pad_sliders = {}
        dummy_slider = Object.new
        dummy_slider.instance_eval {|obj| def value; 0; end }
        dummy_button = Object.new
        dummy_button.instance_eval {|obj| def pressed; false; end }

        # get sliders
        [:x, :y].each do |name|
          if device
            device.get_number_of_sliders.times do |i|
              slider = device.get_slider(i)
              key = slider.name.to_sym
              @pad_sliders[name] = slider if key == name
            end
          end
          @pad_sliders[name] ||= dummy_slider
        end

        # get buttons
        (0..15).each do |idx|
          key = DXRubyRP5.const_get("P_BUTTON#{idx}")
          begin
            button = device ? device.get_button(idx) : dummy_button
          rescue Java::JavaLang::IndexOutOfBoundsException => e
            button = dummy_button
          end
          @pad_buttons[key] = button
        end
        @pushed_pbuttons = []
        @pressed_pbuttons = []
      end
    end

    # for gamepad/joystick
    begin
      device = nil
      Processing::App.sketch_class.class_eval do
        load_library :GameControlPlus
      end
    rescue LoadError => e
      puts "WARN: Couldn't load library for gamepad/joystick"
      puts "If you want to use gamepad or joystick, " \
           "add 'GameControlPlus' library via PDE."
    else
      import "org.gamecontrolplus.ControlIO"
      load_gcp_native_libraries
      begin
        list = ControlIO.get_instance($app).get_devices
        device_types = [
                        Java::NetJavaGamesInput::Controller::Type::STICK,
                        Java::NetJavaGamesInput::Controller::Type::FINGERSTICK,
                        Java::NetJavaGamesInput::Controller::Type::GAMEPAD,
                       ].map(&:to_string)
        device = list.find {|dev| device_types.include?(dev.get_type_name) }
        device.open if device
      rescue Java::JavaLang::NullPointerException
        # cannot get devices when running spec
      end
    end
    setup_pad_input(device)
  end
end
