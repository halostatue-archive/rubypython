require 'rubypython/core_ext/string'
require 'rubypython/python'
require 'rubypython/pythonerror'
require 'rubypython/pyobject'
require 'rubypython/rubypyproxy'
require 'rubypython/pymainclass'


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
#    RubyPython.start
#    cPickle = RubyPython.import "cPickle"
#    puts cPickle.dumps("RubyPython is awesome!").rubify
#    RubyPython.stop
#
#Legacy Mode vs Normal Mode
#---------------------------
#By default RubyPython always returns a proxy class which refers method calls to
#the wrapped Python object. If you instead would like RubyPython to aggressively
#attempt conversion of return values, as it did in RubyPython 0.2.x, then you
#should set {RubyPython.legacy_mode} to true. In this case RubyPython will
#attempt to convert any return value from Python to a native Ruby type, and only
#return a proxy if conversion is not possible. For further examples see
#{RubyPython.legacy_mode}.
module RubyPython

  class << self

    #Determines whether RubyPython is operating in Normal Mode or Legacy Mode.
    #If legacy_mode is true, RubyPython switches into a mode compatible with
    #versions < 0.3.0. All Python objects returned by method invocations are
    #automatically converted to natve Ruby Types if RubyPython knows how to do
    #this. Only if no such conversion is known are the objects wrapped in proxy
    #objects.  Otherwise RubyPython automatically wraps all returned objects as
    #an instance of {RubyPyProxy} or one of its subclasses.
    #@return [Boolean]
    #@example Normal Mode
    #    RubyPython.start
    #    string = RubyPython.import 'string'
    #    ascii_letters = string.ascii_letters # Here ascii_letters is a proxy object
    #    puts ascii_letters.rubify # we use the rubify method to convert it to a
    #                              # native type
    #    RubyPython.stop
    #
    #@example Legacy Mode
    #    RubyPython.legacy_mode = true
    #    RubyPython.start
    #    string = RubyPython.import 'string'
    #    ascii_letters = string.ascii_letters # Here ascii_letters is a native ruby string
    #    puts ascii_letters # No explicit conversion is neccessary
    #    RubyPython.stop
    attr_accessor :legacy_mode

    #Starts ups the Python interpreter. This method **must** be run
    #before using any Python code. The only alternatives are use of the
    #{session} and {run} methods.
    #@return [Boolean] returns true if the interpreter was started here
    #    and false otherwise
    def start
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
    def stop
      if Python.Py_IsInitialized !=0
        PyMain.main = nil
        PyMain.builtin = nil
        RubyPython::Operators.send :class_variable_set, '@@operator', nil
        Python.Py_Finalize
        RubyPython::PyObject::AutoPyPointer.current_pointers.clear
        return true
      end
      false
    end

    #Import a Python module into the interpreter and return a proxy object
    #for it. This is the preferred way to gain access to Python object.
    #@param [String] mod_name the name of the module to import
    #@return [RubyPyModule] a proxy object wrapping the requested
    #module
    def import(mod_name)
      pModule = Python.PyImport_ImportModule mod_name
      if(PythonError.error?)
        raise PythonError.handle_error
      end
      pymod = PyObject.new pModule
      RubyPyModule.new(pymod)
    end

    #Execute the given block, starting the Python interperter before its execution
    #and stopping the interpreter after its execution. The last expression of the
    #block is returned; be careful that this is not a Python object as it will
    #become invalid when the interpreter is stopped.
    #@param [Block] block the code to be executed while the interpreter is running
    #@return the result of evaluating the given block
    def session
      start
      result = yield
      stop
      result
    end

    #The same as {session} except that the block is executed within the scope 
    #of the RubyPython module.
    def run(&block)
      start
      result = module_eval(&block)
      stop
    end
  end
end
