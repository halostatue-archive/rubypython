# RubyPython is a bridge between the Ruby and \Python interpreters. It
# embeds a \Python interpreter in the Ruby application's process using FFI
# and provides a means for wrapping, converting, and calling \Python objects
# and methods.
#
# == Usage
# The \Python interpreter must be started before the RubyPython bridge is
# functional. The user can either manually manage the running of the
# interpreter as shown below, or use the +RubyPython.run+ or
# +RubyPython.session+ methods to automatically start and stop the
# interpreter.
#
#   RubyPython.start
#   cPickle = RubyPython.import "cPickle"
#   puts cPickle.dumps("RubyPython is awesome!").rubify
#   RubyPython.stop
module RubyPython
  VERSION = '0.5.3' #:nodoc:

  # Do not load the FFI interface by default. Wait until the user asks for
  # it.
  @load_ffi = false

  # Indicates whether the \Python DLL has been loaded. For internal use
  # only.
  def self.load_ffi? #:nodoc:
    @load_ffi
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
    # Controls whether RubyPython is operating in <em>Normal Mode</em> or
    # <em>Legacy Mode</em>.
    #
    # === Normal Mode
    # By default, +legacy_mode+ is +false+, meaning that any object returned
    # from a \Python function call will be wrapped in an instance of
    # +RubyPyProxy+ or one of its subclasses. This allows \Python method
    # calls to be forwarded to the \Python object, even if it would otherwise
    # be a native Ruby object.
    #
    #   RubyPython.session do
    #     string = RubyPython.import 'string'
    #     ascii_letters = string.ascii_letters
    #     puts ascii_letters.isalpha # => True
    #     puts ascii_letters.rubify.isalpha # throws NoMethodError
    #   end
    #
    # === Legacy Mode
    # If +legacy_mode+ is +true+, RubyPython automatically tries to convert
    # returned objects to native Ruby object types. If there is no such
    # conversion, the object remains wrapped in +RubyPyProxy+. This
    # behaviour is the same as RubyPython 0.2 and earlier. This mode is not
    # recommended and may be phased out for RubyPython 1.0.
    #
    #   RubyPython.legacy_mode = true
    #   RubyPython.session do
    #     string = RubyPython.import 'string'
    #     ascii_letters = string.ascii_letters
    #     puts ascii_letters.isalpha # throws NoMethodError
    #   end
    attr_accessor :legacy_mode

    # Starts the \Python interpreter. Either +RubyPython.start+,
    # +RubyPython.session+, or +RubyPython.run+ must be run before using any
    # \Python code. Returns +true+ if the interpreter was started; +false+
    # otherwise.
    #
    # [options] Configures the interpreter prior to starting it. Principally
    #           used to provide an alternative \Python interpreter to start.
    #
    # With no options provided:
    #   RubyPython.start
    #   sys = RubyPython.import 'sys'
    #   p sys.version # => "2.6.6"
    #   RubyPython.stop
    #
    # With an alternative \Python executable:
    #   RubyPython.start(:python_exe => 'python2.7')
    #   sys = RubyPython.import 'sys'
    #   p sys.version # => "2.7.1"
    #   RubyPython.stop
    #
    # *NOTE*: In the current version of RubyPython, it _is_ possible to
    # change \Python interpreters in a single Ruby process execution, but it
    # is *strongly* discouraged as this may lead to segmentation faults.
    # This feature is highly experimental and may be disabled in the future.
    def start(options = {})
      RubyPython.configure(options)

      unless @load_ffi
        @load_ffi = true
        @reload = false
        reload_library
      end

      return false if RubyPython::Python.Py_IsInitialized != 0

      if @reload
        reload_library
        @reload = false
      end

      RubyPython::Python.Py_Initialize
      notify :start
      true
    end

    # Stops the \Python interpreter if it is running. Returns +true+ if the
    # intepreter is stopped. All wrapped \Python objects are invalid after
    # invocation of this method. If you need the values within the \Python
    # proxy objects, be sure to call +RubyPyProxy#rubify+ on them.
    def stop
      if defined? Python.Py_IsInitialized and Python.Py_IsInitialized != 0
        Python.Py_Finalize
        notify :stop
        true
      else
        false
      end
    end

    # Import a \Python module into the interpreter and return a proxy object
    # for it.
    #
    # This is the preferred way to gain access to \Python objects.
    #
    # [mod_name] The name of the module to import.
    def import(mod_name)
      if defined? Python.Py_IsInitialized and Python.Py_IsInitialized != 0
        pModule = Python.PyImport_ImportModule mod_name
        raise PythonError.handle_error if PythonError.error?
        pymod = PyObject.new pModule
        RubyPyModule.new(pymod)
      else
        raise "Python has not been started."
      end
    end

    # Starts the \Python interpreter (optionally with options) and +yields+
    # to the provided block. When the block exits for any reason, the
    # \Python interpreter is stopped automatically.
    #
    # The last executed expression of the block is returned. Be careful that
    # the last expression of the block does not return a RubyPyProxy object,
    # because the proxy object will be invalidated when the interpreter is
    # stopped.
    #
    # [options] Configures the interpreter prior to starting it. Principally
    #           used to provide an alternative \Python interpreter to start.
    #
    # *NOTE*: In the current version of RubyPython, it _is_ possible to change
    # \Python interpreters in a single Ruby process execution, but it is
    # *strongly* discouraged as this may lead to segmentation faults. This
    # feature is highly experimental and may be disabled in the future.
    #
    # :call-seq:
    # session(options = {}) { block to execute }
    def session(options = {})
      start(options)
      yield
    ensure
      stop
    end

    # Starts the \Python interpreter (optionally with options) and executes
    # the provided block in the RubyPython module scope. When the block
    # exits for any reason, the \Python interpreter is stopped
    # automatically.
    #
    # The last executed expression of the block is returned. Be careful that
    # the last expression of the block does not return a RubyPyProxy object,
    # because the proxy object will be invalidated when the interpreter is
    # stopped.
    #
    # [options] Configures the interpreter prior to starting it. Principally
    #           used to provide an alternative \Python interpreter to start.
    #
    # *NOTE*: In the current version of RubyPython, it _is_ possible to
    # change \Python interpreters in a single Ruby process execution, but it
    # is *strongly* discouraged as this may lead to segmentation faults.
    # This feature is highly experimental and may be disabled in the future.
    #
    # :call-seq:
    # run(options = {}) { block to execute in RubyPython context }
    def run(options = {}, &block)
      start(options)
      module_eval(&block)
    ensure
      stop
    end

    # Starts the \Python interpreter for a
    # {virtualenv}[http://pypi.python.org/pypi/virtualenv] virtual
    # environment. Returns +true+ if the interpreter was started.
    #
    # [virtualenv]  The root path to the virtualenv-installed \Python
    #               interpreter.
    #
    #   RubyPython.start_from_virtualenv('/path/to/virtualenv')
    #   sys = RubyPython.import 'sys'
    #   p sys.version # => "2.7.1"
    #   RubyPython.stop
    #
    # *NOTE*: In the current version of RubyPython, it _is_ possible to
    # change \Python interpreters in a single Ruby process execution, but it
    # is *strongly* discouraged as this may lead to segmentation faults.
    # This feature is highly experimental and may be disabled in the future.
    def start_from_virtualenv(virtualenv)
      result = start(:python_exe => File.join(virtualenv, "bin", "python"))
      activate
      result
    end

    # Returns an object describing the currently active Python interpreter.
    def python
      RubyPython::Python::EXEC
    end

    # Used to activate the virtualenv.
    def activate
      imp = import("imp")
      imp.load_source("activate_this",
                      File.join(File.dirname(RubyPython::Python::EXEC.python),
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
      @observers ||= []
      @observers.each do |o|
        next if nil === o
        o.update status
      end
    end
    private :notify

    def reload_library
      # Invalidate the current Python instance, if defined.
      if defined? RubyPython::Python::EXEC and RubyPython::Python::EXEC
        RubyPython::Python::EXEC.instance_eval { invalidate! }
      end
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
