require "rubypython/python"
require "rubypython/conversion"
require 'rubypython/macros'
require 'rubypython/conversion'
require 'rubypython/pyobject'
require "rubypython/pymainclass"
require "rubypython/rubypyproxy"

if defined? Fiber
  module RubyPython
    class << self
      # Creates a \Python generator object called +rubypython_generator+
      # that accepts a callback and yields to it.
      #
      # *Note*: This method only exists in the RubyPython if the Fiber
      # exists.
      def generator_type
        @generator_type ||= lambda do
          code = <<-EOM
def rubypython_generator(callback):
  while True:
    yield callback()
          EOM

          globals = PyObject.new({ "__builtins__" => PyMain.builtin.pObject, })
          empty_hash = PyObject.new({})
          ptr = Python.PyRun_String(code, Python::PY_FILE_INPUT, globals.pointer, empty_hash.pointer)
          ptr = Python.PyRun_String("rubypython_generator", Python::PY_EVAL_INPUT, globals.pointer, empty_hash.pointer)
          raise PythonError.handle_error if PythonError.error?
          RubyPyProxy.new(PyObject.new(ptr))
        end.call
      end

      # Creates a Ruby lambda that acts like a \Python generator. Uses
      # +RubyPython.generator_type+ and Fiber to work the generator as a
      # coroutine.
      #
      # *Note*: This method only exists in the RubyPython if the Fiber
      # exists.
      def generator
        return lambda do |*args|
          fib = Fiber.new do
            yield *args
            Python.PyErr_SetNone(Python.PyExc_StopIteration)
            FFI::Pointer::NULL
          end
          generator_type.__call__(lambda { fib.resume })
        end
      end

      # Performs a +Fiber.yield+ with the provided arguments, continuing the
      # coroutine execution of the generator.
      #
      # *Note*: This method only exists in the RubyPython if the Fiber
      # exists.
      def yield(*args)
        Fiber.yield(*args)
      end
    end
  end
end
