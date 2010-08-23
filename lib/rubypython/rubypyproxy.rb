require 'rubypython/py_error'
require 'rubypython/py_object'
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

    #RubyPython checks the attribute dictionary of the wrapped object
    #to check whether it will respond to a method call. This should not
    #return false positives but it may return false negatives.
    def respond_to?(mname)
      return true if super(mname)
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
          return self.__send__ name.to_sym, *args, &block
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

      if(!@pObject.hasAttr(name))
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

    def inspect
      self.__repr__.rubify rescue _inspect
    rescue
      class << self; define_method :_inspect, RubyPyProxy.find_hidden_method(:inspect); end
      _inspect
    end

    def to_s
      self.__str__.rubify rescue _to_s
    rescue
      class << self; define_method :_to_s, RubyPyProxy.find_hidden_method(:to_s); end
      _to_s
    end

  end

  class RubyPyModule < RubyPyProxy
  end

  class RubyPyClass < RubyPyProxy

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

  class RubyPyInstance < RubyPyProxy
  end
end
