# -*- coding: utf-8 -*-
# dxruby_rp5 は ruby-processing の機能を使用しており、ruby-processing
# は gem に同梱されている jruby と Processing のライブラリを使用してい
# る。
# そのため dxruby_rp5 のテストを行うには、gem に同梱されている jruby を
# 経由してテストコードを実行する必要がある。

require 'ruby-processing'

jruby_complete = File.join(RP5_ROOT, 'lib/ruby/jruby-complete.jar')
spec_root = File.expand_path(File.dirname(__FILE__))

command = ['java', '-cp', jruby_complete, 'org.jruby.Main', "#{spec_root}/spec.rb"]
exec *command
