require File::expand_path(File.dirname(__FILE__) + '/../rubypython.rb') if RubyPython.nil?
RubyPython.start

at_exit {RubyPython.stop}