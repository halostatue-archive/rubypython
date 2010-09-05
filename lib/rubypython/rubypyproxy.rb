require 'rubypython/pythonerror'
require 'rubypython/pyobject'
require 'rubypython/conversion'
require 'rubypython/operators'
require 'rubypython/blankobject'

module RubyPython
  #This is the object that the end user will most often be interacting
  #with. It holds a reference to an object in the Python VM an delegates
  #method calls to it, wrapping and returning the results. The user should
  #not worry about reference counting of this object an instance
  #will decrement its objects reference count when it is garbage collected.
  #
  #Note: All RubyPyProxy objects become invalid when the Python interpreter
  #is halted.
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

    #Handles the job of wrapping up anything returned by a {RubyPyProxy}
    #instance. The behavior differs depending on the value of
    #{RubyPython.legacy_mode}. If legacy mode is inactive, every returned
    #object is wrapped by an instance of {RubyPyProxy}. If legacy mode is
    #active, RubyPython first attempts to convert the returned object to a
    #native Ruby type, and then only wraps the object if this fails.
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

    #Moves the old respond_to? method to is_real_method?
    alias :is_real_method? :respond_to?

    #RubyPython checks the attribute dictionary of the wrapped object
    #to check whether it will respond to a method call. This should not
    #return false positives but it may return false negatives. The builitin Ruby
    #respond_to? method has been aliased to is_real_method?. 
    def respond_to?(mname)
      return true if is_real_method?(mname)
      mname = mname.to_s
      return true if mname.end_with? '='
      @pObject.hasAttr(mname)
    end

    #Implements the method call delegation.
    def method_missing(name, *args, &block)
      name = name.to_s

      if(name.end_with? "?")
        begin
          RubyPyProxy.reveal(name.to_sym)
          return self.__send__(name.to_sym, *args, &block)
        rescue RuntimeError => exc
          raise NoMethodError.new(name) if exc.message =~ /Don't know how to reveal/
          raise
        end
      end


      if(name.end_with? "=")
        setter = true
        name.chomp! "="
      else
        setter=false
      end

      if(!@pObject.hasAttr(name) and !setter)
        raise NoMethodError.new(name)
      end


      args = PyObject.convert(*args)

      if setter
        return @pObject.setAttr(name, args[0]) 
      end

      pFunc = @pObject.getAttr(name)

      if pFunc.callable?
        if args.empty? and pFunc.class?
          pReturn = pFunc
        else
          pTuple = PyObject.buildArgTuple(*args)
          pReturn = pFunc.callObject(pTuple)
          if(PythonError.error?)
            raise PythonError.handle_error
          end
        end
      else
        pReturn = pFunc
      end

      return _wrap(pReturn)
    end

    #RubyPython will attempt to translate the wrapped object into a native
    #Ruby object. This will only succeed for simple builtin type.
    def rubify
      @pObject.rubify
    end

    #Returns the string representation of the wrapped object via a call to the
    #object's \_\_repr\_\_ method. Falls back on the default Ruby behavior when
    #this method cannot be found.
    #
    #@return [String]
    def inspect
      self.__repr__.rubify rescue _inspect
    rescue
      class << self; define_method :_inspect, RubyPyProxy.find_hidden_method(:inspect); end
      _inspect
    end

    #Returns the string representation of the wrapped object via a call to the
    #object's \_\_str\_\_ method. Falls back on the default Ruby behavior when
    #this method cannot be found.
    #
    #@return [String]
    def to_s
      self.__str__.rubify rescue _to_s
    rescue
      class << self; define_method :_to_s, RubyPyProxy.find_hidden_method(:to_s); end
      _to_s
    end

    #Converts the wrapped Python object to a Ruby Array. Note that this only converts
    #one level, so a nested array will remain a proxy object. Only wrapped
    #objects which have an \_\_iter\_\_ method may be converted using to_a.
    #
    #Note that for Dict objects, this method returns what you would get in
    #Python, not in Ruby i.e. a_dict.to_a returns an array of the
    #dictionary's keys.
    #@return [Array<RubyPyProxy>]
    #@example List
    #    irb(main):001:0> RubyPython.start
    #    => true
    #    irb(main):002:0> a_list = RubyPython::RubyPyProxy.new [1, 'a', 2, 'b']
    #    => [1, 'a', 2, 'b']
    #    irb(main):003:0> a_list.kind_of? RubyPython::RubyPyProxy
    #    => true
    #    irb(main):004:0> a_list.to_a
    #    => [1, 'a', 2, 'b']
    #    irb(main):005:0> RubyPython.stop
    #    => true
    #    
    #@example Dict
    #    irb(main):001:0> RubyPython.start
    #    => true
    #    irb(main):002:0> a_dict = RubyPython::RubyPyProxy.new({1 => '2', :three => [4,5]})
    #    => {1: '2', 'three': [4, 5]}
    #    irb(main):003:0> a_dict.kind_of? RubyPython::RubyPyProxy
    #    => true
    #    irb(main):004:0> a_dict.to_a
    #    => [1, 'three']
    #    irb(main):005:0> RubyPython.stop
    #    => true
    
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

  end

  #A class to wrap Python Modules. It behaves exactly the same as {RubyPyProxy}.
  #It is just here for Bookkeeping and aesthetics.
  class RubyPyModule < RubyPyProxy
  end

  #A class to wrap Python Classes.
  class RubyPyClass < RubyPyProxy

    #Create an instance of the wrapped class. This is a workaround for the fact
    #that Python classes are meant to be callable.
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

  #An object representing an instance of a Python Class.
  class RubyPyInstance < RubyPyProxy
  end
end
