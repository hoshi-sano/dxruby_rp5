# -*- coding: utf-8 -*-
module Processing
  class Runner
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
