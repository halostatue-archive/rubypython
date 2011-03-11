# This module provides the direct user interface for the RubyPython library.
#
# RubyPython interfaces to the Python C API via the {Python} module using the Ruby
# FFI gem. However, the end user should only worry about dealing with the
# methods made avaiable via the RubyPython module.
#
# Usage
# -----
# It is important to remember that the Python Interpreter must be started
# before the bridge is functional.  This will start the embedded
# interpreter. If this approach is used, the user should remember to call
# RubyPython.stop when they are finished with Python.
#
# @example
#     RubyPython.start
#     cPickle = RubyPython.import "cPickle"
#     puts cPickle.dumps("RubyPython is awesome!").rubify
#     RubyPython.stop
#
# Legacy Mode vs Normal Mode
# ---------------------------
# By default RubyPython always returns a proxy class which refers method calls to
# the wrapped Python object. If you instead would like RubyPython to aggressively
# attempt conversion of return values, as it did in RubyPython 0.2.x, then you
# should set {RubyPython.legacy_mode} to true. In this case RubyPython will attempt to
# convert any return value from Python to a native Ruby type, and only
# return a proxy if conversion is not possible. For further examples see
# {RubyPython.legacy_mode}.
module RubyPython
  VERSION = '0.5.0'

  # Indicates whether the Python DLL has been loaded.
  def self.loaded?
    @loaded
  end
end

require 'rubypython/blankobject'
require 'rubypython/options'
require 'rubypython/python'
require 'rubypython/pythonerror'
require 'rubypython/pyobject'
require 'rubypython/rubypyproxy'
require 'rubypython/pymainclass'
require 'rubypython/pygenerator'

module RubyPython
  class << self
    # Determines whether RubyPython is operating in Normal Mode or Legacy Mode. If
    # legacy_mode is true, RubyPython switches into a mode compatible with
    # versions < 0.3.0. All Python objects returned by method invocations
    # are automatically converted to natve Ruby Types if RubyPython knows how to
    # do this. Only if no such conversion is known are the objects wrapped
    # in proxy objects.  Otherwise RubyPython automatically wraps all returned
    # objects as an instance of {RubyPyProxy} or one of its subclasses.
    #
    # @return [Boolean]
    #
    # @example Normal Mode
    #     RubyPython.start
    #     string = RubyPython.import 'string'
    #
    #     # Here ascii_letters is a proxy object
    #     ascii_letters = string.ascii_letters
    #
    #     # Use the rubify method to convert it to a native type.
    #     puts ascii_letters.rubify
    #     RubyPython.stop
    #
    # @example Legacy Mode
    #     RubyPython.legacy_mode = true
    #     RubyPython.start
    #     string = RubyPython.import 'string'
    #
    #     # Here ascii_letters is a native ruby string
    #     ascii_letters = string.ascii_letters
    #
    #     # No explicit conversion is neccessary
    #     puts ascii_letters
    #     RubyPython.stop
    attr_accessor :legacy_mode

    # Starts up the Python interpreter. This method **must** be run before
    # using any Python code. The only alternatives are use of the {session}
    # and {run} methods.
    #
    # @param options[Hash]  Provides interpreter start options. Principally
    #                       used for providing an alternative Python
    #                       interpreter to start.
    # @return [Boolean] returns true if the interpreter was started here
    #                   and false otherwise
    #
    # @example
    #     RubyPython.start
    #     sys = RubyPython.import 'sys'
    #     p sys.version # => "2.6.6"
    #     RubyPython.stop
    #
    # @example
    #     RubyPython.start(:python_exe => 'python2.7')
    #     sys = RubyPython.import 'sys'
    #     p sys.version # => "2.7.1"
    #     RubyPython.stop
    #
    # @note
    # In the current version of RubyPython, it is not possible to change python
    # interpreters in a single Ruby session. This may change in a future
    # version.
    def start(options = {})
      RubyPython.configure(options)

      unless @loaded
        @loaded = true
        reload_library
      end

      return false if Python.Py_IsInitialized != 0

      if @reload
        reload_library
        @reload = false
      end

      Python.Py_Initialize
      notify :start
      true
    end

    # Stops the Python interpreter if it is running. Returns true if the
    # intepreter is stopped by this invocation. All wrapped Python objects
    # should be considered invalid after invocation of this method.
    #
    # @return [Boolean] returns true if the interpreter was stopped here
    #                   and false otherwise
    def stop
      if defined? Python.Py_IsInitialized and Python.Py_IsInitialized != 0
        Python.Py_Finalize
        notify :stop
        true
      else
        false
      end
    end

    # Import a Python module into the interpreter and return a proxy object
    # for it. This is the preferred way to gain access to Python object.
    #
    # @param [String] mod_name the name of the module to import
    #
    # @return [RubyPyModule] a proxy object wrapping the requested module
    def import(mod_name)
      pModule = Python.PyImport_ImportModule mod_name
      raise PythonError.handle_error if PythonError.error?
      pymod = PyObject.new pModule
      RubyPyModule.new(pymod)
    end

    # Execute the given block, starting the Python interperter before its
    # execution and stopping the interpreter after its execution. The last
    # expression of the block is returned; be careful that this is not a
    # Python object as it will become invalid when the interpreter is
    # stopped.
    #
    # @param options[Hash]  Provides interpreter start options. Principally
    #                       used for providing an alternative Python
    #                       interpreter to start.
    # @param [Block] block  The code to be executed while the interpreter is
    #                       running
    #
    # @return the result of evaluating the given block
    def session(options = {})
      start(options)
      result = yield
      stop
      result
    end

    # The same as {session} except that the block is executed within the
    # scope of the RubyPython module.
    #
    # @param options[Hash]  Provides interpreter start options. Principally
    #                       used for providing an alternative Python
    #                       interpreter to start.
    # @param [Block] block  The code to be executed while the interpreter is
    #                       running
    #
    # @return the result of evaluating the given block
    def run(options = {}, &block)
      start(options)
      result = module_eval(&block)
      stop
      result
    end

    # Starts up the Python interpreter. This method **must** be run before
    # using any Python code. The only alternatives are use of the {session}
    # and {run} methods.
    #
    # @param virtualenv[String] Provides the root path to the virtualenv-
    #                           installed Python.
    # @return [Boolean] returns true if the interpreter was started here
    #                   and false otherwise
    #
    # @example
    #     RubyPython.start_from_virtualenv('/path/to/virtualenv')
    #     sys = RubyPython.import 'sys'
    #     p sys.version # => "2.7.1"
    #     RubyPython.stop
    #
    # @note
    # In the current version of RubyPython, it is not possible to change python
    # interpreters in a single Ruby session. This may change in a future
    # version.
    def start_from_virtualenv(virtualenv)
      result = start(:python => File.join(virtualenv, "bin", "python"))
      activate
      result
    end

    # Used to activate the virtualenv.
    def activate
      imp = import("imp")
      imp.load_source("activate_this",
                      File.join(File.dirname(RubyPython::Python::PYTHON.python),
                      "activate_this.py"))
    end
    private :activate

    def add_observer(object)
      @observers ||= []
      @observers << object
      true
    end
    private :add_observer

    def notify(status)
      if not @observers.nil?
        @observers.each do |o|
          o.update status
        end
      end
    end
    private :notify

    def reload_library
      remove_const :Python
      load RubyPython::PYTHON_RB
      true
    end
    private :reload_library
  end

  add_observer PyMain
  add_observer Operators
  add_observer PyObject::AutoPyPointer
end
