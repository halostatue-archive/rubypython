require 'rubypython/py_error'
require 'rubypython/rubypyapi/py_object'
require 'rubypython/rubypyapi/conversion'
require 'rubypython/blankobject'

module RubyPython
  module RubyPyApi

    #This is the object that the end user will most often be interacting
    #with. It holds a reference to an object in the Python VM an delegates
    #method calls to it, wrapping and returning the results. The user should
    #not worry about reference counting of this object an instance
    #will decrement its objects reference count when it is garbage collected.
    #
    #Note: All RubyPyProxy objects become invalid when the Python interpreter
    #is halted.
    class RubyPyProxy < BlankObject

      attr_reader :pObject

      def initialize(pObject)
        if pObject.kind_of? RubyPyApi::PyObject
          @pObject = pObject
        else
          @pObject = RubyPyApi::PyObject.new pObject
        end
      end

      def _setAttr(name, *args) #:nodoc:
        @pObject.setAttr(name, args[0])
      end

      def _wrap(pyobject) #:nodoc:
        if pyobject.class?
          RubyPyApi::RubyPyClass.new(pyobject)
        elsif RubyPyApi.legacy_mode
          pyobject.rubify
        else
          RubyPyApi::RubyPyProxy.new(pyobject)
        end
      rescue Conversion::UnsupportedConversion => exc
        RubyPyApi::RubyPyProxy.new pyobject
      end

      #RubyPython checks the attribute dictionary of the wrapped object
      #to check whether it will respond to a method call. This should not
      #return false positives but it may return false negatives.
      def respond_to?(mname)
        @pObject.hasAttr(mname.to_s)
      end

      def method_missing(name, *args, &block) #:nodoc:
        name = name.to_s
        
        if(name.end_with? "=")
          setter = true
          name.chomp! "="
        else
          setter=false
        end
        
        if(!@pObject.hasAttr(name))
          raise NoMethodError.new(name)
        end

        
        args = RubyPyApi::PyObject.convert(*args)

        if setter
          return _setAttr(name,*args)
        end

        pFunc = @pObject.getAttr(name)
        
        if pFunc.callable?
          if args.empty? and pFunc.class?
            pReturn = pFunc
          else
            pTuple = RubyPyApi::PyObject.buildArgTuple(*args)
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
          
    end

    class RubyPyModule < RubyPyProxy
    end

    class RubyPyClass < RubyPyProxy

      def new(*args)
        args = RubyPyApi::PyObject.convert(*args)
        pTuple = RubyPyApi::PyObject.buildArgTuple(*args)
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
end
