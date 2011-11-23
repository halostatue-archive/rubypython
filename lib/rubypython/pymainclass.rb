require 'rubypython/blankobject'
require 'singleton'

module RubyPython
  # A singleton object providing access to the \Python <tt>__main__</tt> and
  # <tt>__builtin__</tt> modules. This can be conveniently accessed through
  # +PyMain+. The <tt>__main__</tt> namespace is searched before the
  # <tt>__builtin__</tt> namespace. As such, naming clashes will be resolved
  # in that order.
  #
  #   RubyPython::PyMain.dir("dir") # => ['__add__', '__class__', … ]
  #
  # === Block Syntax
  # PyMainClass provides experimental block support for called methods. A
  # block may be passed to a method call and the object returned by the
  # function call will be passed as an argument to the block.
  #
  #   RubyPython::PyMain.dir("dir") { |a| a.rubify.map { |e| e.to_sym } }
  #     # => [:__add__, :__class__, :__contains__, … ]
  class PyMainClass < RubyPython::BlankObject
    include Singleton

    # Returns a proxy object wrapping the \Python <tt>__main__</tt> namespace.
    def main
      @main ||= RubyPython.import "__main__"
    end

    # Returns a proxy object wrapping the \Python <tt>__builtin__</tt>
    # namespace.
    def builtin
      @builtin ||= RubyPython.import "__builtin__"
    end

    # Delegates any method calls on this object to the \Python
    # <tt>__main__</tt> or <tt>__builtin__</tt> namespaces, in that order. If
    # a block is provided, the result of calling the \Python method will be
    # yielded as an argument to the block.
    #
    # [name] The name of the \Python method or function to call.
    # [args] The arguments to pass to the \Python method.
    # [block] A block to execute with the result of calling the \Python
    # method. If a block is provided, the result of the block is returned,
    # not the result of the \Python method.
    def method_missing(name, *args, &block)
      proxy = if main.respond_to?(name)
                main
              elsif builtin.respond_to?(name)
                builtin
              else
                super(name, *args)
              end
      result = if proxy.is_real_method?(name)
                 proxy.__send__(name, *args)
               else
                 proxy.__send__(:method_missing, name, *args)
               end

      if block
        block.call(result)
      else
        result
      end
    end

    # Called by RubyPython when the interpreter is started or stopped so
    # that the neccesary preparation or cleanup can be done. For internal
    # use only.
    def python_interpreter_update(status)
      case status
      when :stop
        @main = nil
        @builtin = nil
      end
    end
    private :python_interpreter_update
  end

  # The accessible instance of PyMainClass.
  PyMain = RubyPython::PyMainClass.instance
end
