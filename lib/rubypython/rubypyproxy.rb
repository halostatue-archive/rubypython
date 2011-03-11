require 'rubypython/pythonerror'
require 'rubypython/pyobject'
require 'rubypython/conversion'
require 'rubypython/operators'
require 'rubypython/blankobject'

module RubyPython
  # This is the object that the end user will most often be interacting
  # with. It holds a reference to an object in the Python VM an delegates
  # method calls to it, wrapping and returning the results. The user should
  # not worry about reference counting of this object an instance will
  # decrement its objects reference count when it is garbage collected.
  #
  # Note: All RubyPyProxy objects become invalid when the Python interpreter
  # is halted.
  #
  # Calling Methods With Blocks
  # -----------------------------
  # Any method which is forwarded to a Python object may be called with
  # a block. The result of the method will passed as the argument to
  # that block.
  #
  # @example Supplying a block to a method call
  #   irb(main):001:0> RubyPython.start
  #   => true
  #   irb(main):002:0> RubyPython::PyMain.float(10) do |f|
  #   irb(main):003:1*     2*f.rubify
  #   irb(main):004:1> end
  #   => 20.0
  #   irb(main):005:0> RubyPython.stop
  #   => true
  #
  #
  # Passing Procs and Methods to methods
  # -------------------------------------
  # RubyPython now supports passing Proc and Method objects to Python
  # methods. The Proc or Method object must be passed explicitly. As
  # seen above, supplying a block to a method will result in the return
  # value of the method call being passed to the block.
  #
  # When a Proc or Method is supplied as a callback, then arguments that
  # it will be called with will be wrapped Python objects.
  #
  # @example Passing a Proc to Python
  #   # Python Code
  #   def apply_callback(callback, argument):
  #     return callback(argument)
  #
  #   # IRB Session
  #   irb(main):001:0> RubyPython.start
  #   => true
  #   irb(main):002:0> sys = RubyPython.import 'sys'
  #   => <module 'sys' (built-in)>
  #   irb(main):003:0> sys.path.append('.')
  #   => None
  #   irb(main):004:0> sample = RubyPython.import 'sample'
  #   => <module 'sample' from './sample.pyc'>
  #   irb(main):005:0> callback = Proc.new do |arg|
  #   irb(main):006:1*   arg * 2
  #   irb(main):007:1> end
  #   => # <Proc:0x000001018df490@(irb):5>
  #   irb(main):008:0> sample.apply_callback(callback, 21).rubify
  #   => 42
  #   irb(main):009:0> RubyPython.stop
  class RubyPyProxy < BlankObject
    include Operators

    attr_reader :pObject

    def initialize(pObject)
      if pObject.kind_of? PyObject
        @pObject = pObject
      else
        @pObject = PyObject.new pObject
      end
    end

    # Handles the job of wrapping up anything returned by a {RubyPyProxy}
    # instance. The behavior differs depending on the value of
    # {RubyPython.legacy_mode}. If legacy mode is inactive, every returned object
    # is wrapped by an instance of {RubyPyProxy}. If legacy mode is active,
    # RubyPython first attempts to convert the returned object to a native Ruby
    # type, and then only wraps the object if this fails.
    def _wrap(pyobject)
      if pyobject.class?
        RubyPyClass.new(pyobject)
      elsif RubyPython.legacy_mode
        pyobject.rubify
      else
        RubyPyProxy.new(pyobject)
      end
    rescue Conversion::UnsupportedConversion => exc
      RubyPyProxy.new pyobject
    end

    reveal(:respond_to?)

    # Moves the old respond_to? method to is_real_method?
    alias :is_real_method? :respond_to?

    # RubyPython checks the attribute dictionary of the wrapped object to check
    # whether it will respond to a method call. This should not return false
    # positives but it may return false negatives. The builitin Ruby
    # respond_to? method has been aliased to is_real_method?.
    def respond_to?(mname)
      return true if is_real_method?(mname)
      mname = mname.to_s
      return true if mname =~ /=$/
      @pObject.hasAttr(mname)
    end

    # Implements the method call delegation.
    def method_missing(name, *args, &block)
      name = name.to_s

      if name =~ /\?$/
        begin
          RubyPyProxy.reveal(name.to_sym)
          return self.__send__(name.to_sym, *args, &block)
        rescue RuntimeError => exc
          raise NoMethodError.new(name) if exc.message =~ /Don't know how to reveal/
          raise
        end
      end

      setter = kwargs = false

      if name =~ /=$/
        setter = true
        name.chomp! "="
      elsif name =~ /!$/
        kwargs = true
        name.chomp! "!"
      end

      if !@pObject.hasAttr(name) and !setter
        raise NoMethodError.new(name)
      end

      if setter
        return @pObject.setAttr(name, PyObject.convert(*args)[0])
      end

      pFunc = @pObject.getAttr(name)

      if pFunc.callable?
        if args.empty? and pFunc.class?
          pReturn = pFunc
        else
          if kwargs and args.last.is_a?(Hash)
            pKeywords = *PyObject.convert(args.pop)
          end

          args = PyObject.convert(*args)
          pTuple = PyObject.buildArgTuple(*args)
          pReturn = if pKeywords
            pFunc.callObjectKeywords(pTuple, pKeywords)
          else
            pFunc.callObject(pTuple)
          end
          if PythonError.error?
            raise PythonError.handle_error
          end
        end
      else
        pReturn = pFunc
      end

      return _wrap(pReturn)
    end

    # RubyPython will attempt to translate the wrapped object into a native Ruby
    # object. This will only succeed for simple builtin type.
    def rubify
      @pObject.rubify
    end

    # Returns the string representation of the wrapped object via a call to
    # the object's \_\_repr\_\_ method.
    #
    # @return [String]
    def inspect
      self.__repr__.rubify
    rescue PythonError, NoMethodError
      RubyPython::PyMain.repr(self).rubify
    end

    # Returns the string representation of the wrapped object via a call to the
    # object's \_\_str\_\_ method.
    #
    # @return [String]
    def to_s
      self.__str__.rubify
    rescue PythonError, NoMethodError
      RubyPython::PyMain.str(self).rubify
    end

    # Converts the wrapped Python object to a Ruby Array. Note that this
    # only converts one level, so a nested array will remain a proxy object.
    # Only wrapped objects which have an \_\_iter\_\_ method may be
    # converted using to_a.
    #
    # Note that for Dict objects, this method returns what you would get in
    # Python, not in Ruby i.e. a\_dict.to\_a returns an array of the
    # dictionary's keys.
    # @return [Array<RubyPyProxy>]
    # @example List
    #     irb(main):001:0> RubyPython.start
    #     => true
    #     irb(main):002:0> a_list = RubyPython::RubyPyProxy.new [1, 'a', 2, 'b']
    #     => [1, 'a', 2, 'b']
    #     irb(main):003:0> a_list.kind_of? RubyPython::RubyPyProxy
    #     => true
    #     irb(main):004:0> a_list.to_a
    #     => [1, 'a', 2, 'b']
    #     irb(main):005:0> RubyPython.stop
    #     => true
    #
    # @example Dict
    #     irb(main):001:0> RubyPython.start
    #     => true
    #     irb(main):002:0> a_dict = RubyPython::RubyPyProxy.new({1 => '2', :three => [4,5]})
    #     => {1: '2', 'three': [4, 5]}
    #     irb(main):003:0> a_dict.kind_of? RubyPython::RubyPyProxy
    #     => true
    #     irb(main):004:0> a_dict.to_a
    #     => [1, 'three']
    #     irb(main):005:0> RubyPython.stop
    #     => true
    def to_a
      iter = self.__iter__
      ary = []
      loop do
        ary << iter.next()
      end
    rescue PythonError => exc
      raise if exc.message !~ /StopIteration/
      ary
    end

    def methods
      return pObject.dir.map { |x| x.to_sym }
    end

    def to_enum
      return PyEnumerable.new(@pObject)
    end
  end

  # A class to wrap Python Modules. It behaves exactly the same as
  # {RubyPyProxy}. It is just here for Bookkeeping and aesthetics.
  class RubyPyModule < RubyPyProxy; end

  # A class to wrap Python Classes.
  class RubyPyClass < RubyPyProxy
    # Create an instance of the wrapped class. This is a workaround for the
    # fact that Python classes are meant to be callable.
    def new(*args)
      args = PyObject.convert(*args)
      pTuple = PyObject.buildArgTuple(*args)
      pReturn = @pObject.callObject(pTuple)
      if PythonError.error?
        raise PythonError.handle_error
      end
      RubyPyInstance.new pReturn
    end
  end

  # An object representing an instance of a Python Class.
  class RubyPyInstance < RubyPyProxy; end

  class PyEnumerable < RubyPyProxy
    include Enumerable

    def each
      iter = self.__iter__
      while true
        begin
          yield iter.next
        rescue RubyPython::PythonError => exc
          return if exc.message =~ /StopIteration/
        end
      end
    end
  end
end
