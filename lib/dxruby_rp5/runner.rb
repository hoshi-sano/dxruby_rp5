# -*- coding: utf-8 -*-
module Processing
  class Runner
    DXRP5_HELP_MESSAGE = <<-EOS
  Version: #{DXRubyRP5::VERSION}

  Usage:
    dxrp5 run path/to/sketch

  Common options:
    --nojruby:  do not use the installed version of jruby, instead use our vendored
                jarred one (required for shader sketches, and some others).

  Examples:
    dxrp5 run my_sketch.rb
    dxrp5 --nojruby run my_sketch.rb

      EOS

    def show_version
      puts  <<-EOS
  Ruby-Processing version #{Processing::VERSION}
  DXRuby_RP5 version #{DXRubyRP5::VERSION}
      EOS
    end

    def show_help
      puts DXRP5_HELP_MESSAGE
    end

    private

    # changed runner path from original.
    def spin_up(starter_script, sketch, args)
      runner = "#{DXRUBY_RP5_ROOT}/lib/dxruby_rp5/runners/#{starter_script}"
      java_args = discover_java_args(sketch)
      warn("The --jruby flag is no longer required") if @options.jruby
      command = @options.nojruby ?
         ['java', java_args, '-cp', jruby_complete, 'org.jruby.Main', runner, sketch, args].flatten :
         ['jruby', java_args, runner, sketch, args].flatten
      exec *command
    end
  end
end
