require 'rubypython/wrapper_extensions'


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
    RubyPyApi.stop
  end

  def self.import(mod)
    pymod=RubyPyApi.import(mod)
    if(PythonError.error?)
      rbType = RubyPyApi::PyObject.new nil
      rbValue = RubyPyApi::PyObject.new nil
      rbTraceback = RubyPyApi::PyObject.new nil
      PythonError.fetch(rbType,rbValue,rbTraceback)
      PythonError.clear
      raise PythonError.new(rbType.getAttr("__name__").rubify)
    end
    RubyPyApi::RubyPyProxy.new(pymod)

  end
end


