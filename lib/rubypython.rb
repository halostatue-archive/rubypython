require 'rubypython/python'
require 'rubypython/py_object'
require 'rubypython/rubypyproxy'
require 'rubypython/blankobject'
require 'singleton'

if RUBY_VERSION == "1.8.6"
  class String
    #This is necessary for Ruby versions 1.8.6 and below as 
    #String#end_with? is not defined in this case.
    def end_with?(c)
      self[-1].chr == c
    end
  end
end


#This module provides the direct user interface for the RubyPython extension.
#
#RubyPython interfaces to the Python C API via the {Python} module using the
#Ruby FFI gem. However, the end user should only worry about dealing with the
#methods made avaiable via the RubyPython module.
#
#Usage
#-----
#It is important to remember that the Python Interpreter must be
#started before the bridge is functional.  This will start the embedded
#interpreter. If this approach is used, the user should remember to call
#RubyPython.stop when they are finished with Python.
#@example
#  RubyPython.start
#  cPickle = RubyPython.import "cPickle"
#  puts cPickle.dumps "RubyPython is awesome!"
#  RubyPython.stop
module RubyPython

  @@legacy_mode = false

  #Starts ups the Python interpreter. This method **must** be run
  #before using any Python code. The only alternatives are use of the
  #{session} and {run} methods.
  #@return [Boolean] returns true if the interpreter was started here
  #    and false otherwise
  def self.start
    if Python.Py_IsInitialized != 0
      return false
    end
    Python.Py_Initialize
    true
  end

  #Stops the Python interpreter if it is running. Returns true if the
  #intepreter is stopped by this invocation. All wrapped Python objects
  #should be considered invalid after invocation of this method.
  #@return [Boolean] returns true if the interpreter was stopped here
  #    and false otherwise
  def self.stop
    if Python.Py_IsInitialized !=0
      PyMain.main = nil
      PyMain.builtin = nil
      RubyPython::Operators.class_variable_set('@@operator', nil)
      Python.Py_Finalize
      return true
    end
    false
  end

  #Import a Python module into the interpreter and return a proxy object
  #for it. This is the preferred way to gain access to Python object.
  #@param [String] mod_name the name of the module to import
  #@return [RubyPyModule] a proxy object wrapping the requested
  #module
  def self.import(mod_name)
    pModule = Python.PyImport_ImportModule mod_name
    pymod = PyObject.new pModule
    if(PythonError.error?)
      raise PythonError.handle_error
    end
    RubyPyModule.new(pymod)
  end

  #Switch RubyPython into a mode compatible with versions < 0.3.0. All
  #Python objects returned by method invocations are automatically converted
  #to natve Ruby Types if RubyPython knows how to do this. Only if no such
  #conversion is known are the objects wrapped in proxy objects.
  #@return [void]
  def self.legacy_mode=(on_off)
    @@legacy_mode = on_off
  end

  #Set RubyPython to automatically wrap all returned objects as an instance
  #of {RubyPyProxy} or one of its subclasses.
  #@return [Boolean]
  def self.legacy_mode
    @@legacy_mode
  end

  #Execute the given block, starting the Python interperter before its execution
  #and stopping the interpreter after its execution. The last expression of the
  #block is returned; be careful that this is not a Python object as it will
  #become invalid when the interpreter is stopped.
  #@param [Block] block the code to be executed while the interpreter is running
  #@return the result of evaluating the given block
  def self.session
    start
    begin
      result = yield
    ensure
      stop
    end
    result
  end

  #The same as {session} except that the block is executed within the scope 
  #of the RubyPython module.
  def self.run(&block)
    start
    begin
      result = module_eval(&block)
    ensure
      stop
    end
    result
  end
end


# A singleton object providing access to the python \_\_main\_\_ and \_\_builtin\_\_ modules.
# This can be conveniently accessed through the already instaniated PyMain constant.
# The \_\_main\_\_ namespace is searched before the \_\_builtin\_\_ namespace. As such,
# naming clashes will be resolved in that order.
#
# ## Block Syntax
# The PyMainClass object provides somewhat experimental block support.  A block
# may be passed to a method call and the object returned by the function call
# will be passed as an argument to the block.
class PyMainClass < RubyPython::BlankObject
  include Singleton
  attr_writer :main, :builtin
  
  #@return [RubyPyModule] a proxy object wrapping the Python \__main\__
  #namespace.
  def main 
    @main||=RubyPython.import "__main__"
  end
  
  #@return [RubyPyModule] a proxy object wrapping the Python \__builtin\__
  #namespace.
  def builtin
    @builtin||=RubyPython.import "__builtin__"
  end
  
  #Delegates any method calls on this object to the Python \__main\__ or
  #\__builtin\__ namespaces. Method call resolution occurs in that order.
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

PyMain = PyMainClass.instance
