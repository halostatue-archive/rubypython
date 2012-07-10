require 'rubypython/pythonerror'
require 'rubypython/pyobject'
require 'rubypython/conversion'
require 'rubypython/operators'
require 'rubypython/blankobject'

module RubyPython
  # In most cases, users will interact with RubyPyProxy objects that hold
  # references to active objects in the \Python interpreter. RubyPyProxy
  # delegates method calls to \Python objects, wrapping and returning the
  # results as RubyPyProxy objects.
  #
  # The allocation, deallocation, and reference counting on RubyPyProxy
  # objects is automatic: RubyPython takes care of it all. When the object
  # is garbage collected, the instance will automatically decrement its
  # object reference count.
  #
  # [NOTE:]  All RubyPyProxy objects become invalid when the \Python
  #          interpreter is halted.
  #
  # == Calling Methods With Blocks
  # Any method which is forwarded to a \Python object may be called with a
  # block. The result of the method will passed as the argument to that
  # block.
  #
  #   RubyPython.run do
  #     sys = RubyPython.import 'sys'
  #     sys.version { |v| v.rubify.split(' ') }
  #   end
  #   # => [ "2.6.1", … ]
  #   
  # == Passing Procs and Methods to \Python Methods
  # RubyPython supports passing Proc and Method objects to \Python methods.
  # The Proc or Method object must be passed explicitly. As seen above,
  # supplying a block to a method will result in the return value of the
  # method call being passed to the block.
  #
  # When a Proc or Method is supplied as a callback, then arguments that it
  # will be called with will be wrapped \Python objects. It will therefore
  # typically be necessary to write a wrapper around any Ruby callback that
  # requires native Ruby objects.
  #
  #   # Python Code: sample.py
  #   def apply_callback(callback, argument):
  #     return callback(argument)
  #
  #   # IRB Session
  #   >> RubyPython.start
  #   => true
  #   >> sys = RubyPython.import 'sys'
  #   => <module 'sys' (built-in)>
  #   >> sys.path.append('.')
  #   => None
  #   >> sample = RubyPython.import 'sample'
  #   => <module 'sample' from './sample.pyc'>
  #   >> callback = Proc.new { |arg| arg * 2 }
  #   => # <Proc:0x000001018df490@(irb):5>
  #   >> sample.apply_callback(callback, 21).rubify
  #   => 42
  #   >> RubyPython.stop
  #   => true
  class RubyPyProxy < BlankObject
    include Operators

    attr_reader :pObject

    # Creates a \Python proxy for the provided Ruby object.
    #
    # Only the following Ruby types can be represented in \Python:
    # * String
    # * Array
    # * Hash
    # * Fixnum
    # * Bignum
    # * Float
    # * Symbol (as a String)
    # * Proc
    # * Method
    # * +true+ (as True)
    # * +false+ (as False)
    # * +nil+ (as None)
    def initialize(pObject)
      if pObject.kind_of? PyObject
        @pObject = pObject
      else
        @pObject = PyObject.new pObject
      end
    end

    # Handles the job of wrapping up anything returned by a RubyPyProxy
    # instance. Every returned # object is wrapped by an instance of +RubyPyProxy+
    def _wrap(pyobject)
      if pyobject.class?
        RubyPyClass.new(pyobject)
      else
        RubyPyProxy.new(pyobject)
      end
    rescue Conversion::UnsupportedConversion => exc
      RubyPyProxy.new pyobject
    end
    private :_wrap

    reveal(:respond_to?)

    # The standard Ruby +#respond_to?+ method has been renamed to allow
    # RubyPython to query if the proxied \Python object supports the method
    # desired. Setter methods (e.g., +foo=+) are always supported.
    alias :is_real_method? :respond_to?

    # RubyPython checks the attribute dictionary of the wrapped object to
    # check whether it will respond to a method call. This should not return
    # false positives but it may return false negatives. The built-in Ruby
    # respond_to? method has been aliased to is_real_method?.
    def respond_to?(mname)
      return true if is_real_method?(mname)
      mname = mname.to_s
      return true if mname =~ /=$/
      @pObject.hasAttr(mname)
    end

    # Delegates method calls to proxied \Python objects.
    #
    # == Delegation Rules
    # 1. If the method ends with a question-mark (e.g., +nil?+), it can only
    #    be a Ruby method on RubyPyProxy. Attempt to reveal it (RubyPyProxy
    #    is a BlankObject) and call it.
    # 2. If the method ends with equals signs (e.g., +value=+) it's a setter
    #    and we can always set an attribute on a \Python object.
    # 3. If the method ends with an exclamation point (e.g., +foo!+) we are
    #    attempting to call a method with keyword arguments.
    # 4. The Python method or value will be called, if it's callable.
    # 5. RubyPython will wrap the return value in a RubyPyProxy object
    # 6. If a block has been provided, the wrapped return value will be
    #    passed into the block.
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

      kwargs = false

      if name =~ /=$/
        return @pObject.setAttr(name.chomp('='),
                                PyObject.convert(*args).first)
      elsif name =~ /!$/
        kwargs = true
        name.chomp! "!"
      end

      raise NoMethodError.new(name) if !@pObject.hasAttr(name)

      pFunc = @pObject.getAttr(name)

      if pFunc.callable?
        if args.empty? and pFunc.class?
          pReturn = pFunc
        else
          if kwargs and args.last.is_a?(Hash)
            pKeywords = PyObject.convert(args.pop).first
          end
          pReturn = _method_call(pFunc, args, pKeywords)
          pFunc.xDecref
        end
      else
        pReturn = pFunc
      end

      result = _wrap(pReturn)

      if block
        block.call(result)
      else
        result
      end
    end

    #Handles the of calling a wrapped callable Python object at a higher level
    #than +PyObject#callObject+. For internal use only.
    def _method_call(pFunc, args, pKeywords)
      orig_args = args
      #Convert will create a new reference to any python object that is not
      #alreay wrapped. We will need to DecRef these when we are done
      args = PyObject.convert(*args)
      pTuple = PyObject.buildArgTuple(*args)
      pReturn = if pKeywords
        pFunc.callObjectKeywords(pTuple, pKeywords)
      else
        pFunc.callObject(pTuple)
      end

      # Clean up unused Python vars instead of waiting on Ruby's GC to
      # do it.
      pTuple.xDecref
      pKeywords.xDecref if pKeywords
      raise PythonError.handle_error if PythonError.error?
      pReturn
    end
    private :_method_call

    # RubyPython will attempt to translate the wrapped object into a native
    # Ruby object. This will only succeed for simple built-in type.
    def rubify
      @pObject.rubify
    end

    # Returns the String representation of the wrapped object via a call to
    # the object's <tt>__repr__</tt> method, or the +repr+ method in PyMain.
    def inspect
      self.__repr__.rubify
    rescue PythonError, NoMethodError
      RubyPython::PyMain.repr(self).rubify
    end

    # Returns the string representation of the wrapped object via a call to
    # the object's <tt>__str__</tt> method or the +str+ method in PyMain.
    def to_s
      self.__str__.rubify
    rescue PythonError, NoMethodError
      RubyPython::PyMain.str(self).rubify
    end

    # Converts the wrapped \Python object to a Ruby Array. Note that this
    # only converts one level, so a nested array will remain a proxy object.
    # Only wrapped objects which have an <tt>__iter__</tt> method may be
    # converted using +to_a+.
    #
    # Note that for \Python Dict objects, this method returns what you would
    # get in \Python, not in Ruby: +a_dict.to_a+ returns an array of the
    # dictionary's keys.
    #
    # === List #to_a Returns an Array
    #   >> RubyPython.start
    #   => true
    #   >> list = RubyPython::RubyPyProxy.new([1, 'a', 2, 'b'])
    #   => [1, 'a', 2, 'b']
    #   >> list.kind_of? RubyPython::RubyPyProxy
    #   => true
    #   >> list.to_a
    #   => [1, 'a', 2, 'b']
    #   >> RubyPython.stop
    #   => true
    #
    # === Dict #to_a Returns An Array of Keys
    #   >> RubyPython.start
    #   => true
    #   >> dict = RubyPython::RubyPyProxy.new({1 => '2', :three => [4,5]})
    #   => {1: '2', 'three': [4, 5]}
    #   >> dict.kind_of? RubyPython::RubyPyProxy
    #   => true
    #   >> dict.to_a
    #   => [1, 'three']
    #   >> RubyPython.stop
    #   => true
    #
    # === Non-Array Values Do Not Convert
    #   >> RubyPython.start
    #   => true
    #   >> item = RubyPython::RubyPyProxy.new(42)
    #   => 42
    #   >> item.to_a
    #   NoMethodError: __iter__
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

    # Returns the methods on the \Python object by calling the +dir+
    # built-in.
    def methods
      pObject.dir.map { |x| x.to_sym }
    end

    # Creates a PyEnumerable for this object. The object must have the
    # <tt>__iter__</tt> method.
    def to_enum
      PyEnumerable.new(@pObject)
    end
  end

  # A class to wrap \Python modules. It behaves exactly the same as
  # RubyPyProxy. It is just here for Bookkeeping and aesthetics.
  class RubyPyModule < RubyPyProxy; end

  # A class to wrap \Python classes.
  class RubyPyClass < RubyPyProxy
    # Create an instance of the wrapped class. This is a workaround for the
    # fact that \Python classes are meant to be callable.
    def new(*args)
      pReturn =  _method_call(@pObject, args, nil)
      RubyPyInstance.new pReturn
    end
  end

  # An object representing an instance of a \Python class. It behaves
  # exactly the same as RubyPyProxy. It is just here for Bookkeeping and
  # aesthetics.
  class RubyPyInstance < RubyPyProxy; end

  # An object representing a Python enumerable object.
  class PyEnumerable < RubyPyProxy
    include Enumerable

    def each
      iter = self.__iter__
      loop do
        begin
          yield iter.next
        rescue RubyPython::PythonError => exc
          return if exc.message =~ /StopIteration/
        end
      end
    end
  end
end
