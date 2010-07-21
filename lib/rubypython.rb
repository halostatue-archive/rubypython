require 'rubypython/rubypyapi'
require 'rubypython/rubypyproxy'
require 'rubypython/blankobject'
require 'singleton'

if RUBY_VERSION == "1.8.6"
  class String
    def end_with?(c)
      self[-1].chr == c
    end
  end
end

RubyPythonBridge = RubyPyApi


=begin rdoc
This module provides the direct user interface for the RubyPython extension.

The majority of the functionality lies in the _RubyPyApi_ module, which is provided
by the C extension. However, the end user should only worry about dealing with the RubyPython
module as that is designed for user interaction.

==Usage  
It is important to remember that the Python Interpreter must be started before the bridge
is functional. 
This will start the embedded interpreter. If this approach is used, the user should
remember to call RubyPython.stop when they are finished with Python.
Example:
  RubyPython.start
  cPickle=RubyPython.import "cPickle"
  puts cPickle.dumps "RubyPython is awesome!"
  RubyPython.stop
=end
module RubyPython
  def self.start
    RubyPyApi.start
  end

  def self.stop
    PyMain.main = nil
    PyMain.builtin = nil
    RubyPyApi.stop
  end

  def self.import(mod)
    pymod = RubyPyApi.import(mod)
    if(PythonError.error?)
      raise PythonError.handle_error
    end
    RubyPyApi::RubyPyModule.new(pymod)
  end

  def self.legacy_mode=(on_off)
    RubyPyApi.legacy_mode = on_off
  end

  def self.legacy_mode
    RubyPyApi.legacy_mode
  end

  def self.session
    start
    result = yield
    stop
    result
  end

  def self.run(&block)
    start
    result = module_eval &block
    stop
    result
  end
end


# A singleton object providing access to the python __main__ and __builtin__ modules.
# This can be conveniently accessed through the already instaniated PyMain constant.
# The __main__ namespace is searched beofre the __builtin__ namespace. As such,
# naming clashes will be resolved in that order.
#
# == Block Syntax
# The PyMainClass object provides somewhat experimental block support.
# A block may be passed to a method call and the object returned by the function call
# will be passed as an argument to the block.
class PyMainClass < RubyPyApi::BlankObject
  include Singleton
  attr_writer :main, :builtin
  #:nodoc:
  def main
    @main||=RubyPython.import "__main__"
  end
  
  #:nodoc:
  def builtin
    @builtin||=RubyPython.import "__builtin__"
  end
  
  #:nodoc:
  def method_missing(name,*args,&block)
    begin
      result=main.__send__(name,*args)
    rescue NoMethodError
      begin
        result=builtin.__send__(name,*args)
      rescue NoMethodError
        super(name,*args)
      end
    end
    if(block)
      return block.call(result)
    end
    return result
  end
end

# See _PyMainClass_
PyMain=PyMainClass.instance
