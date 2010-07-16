require 'rubypython/rubypyapi/py_error'
require 'rubypython/rubypyapi/py_object'

module RubyPyApi

  class NullPObjectError < RuntimeError
  end

  class RubyPyProxy 

    attr_reader :pObject

    def initialize(pObject)
      if pObject.kind_of? RubyPyApi::PyObject
        @pObject = pObject
      else
        @pObject = RubyPyApi::PyObject.new pObject
      end
    end

    def _setAttr(name, *args)
      @pObject.setAttr(name, args[0])
    end

    def _wrap(pyobject)
      RubyPyApi::RubyPyProxy.new(pyobject)
    end

    def method_missing(name, *args, &block)
      name=name.to_s
      
      if(name.end_with? "=")
	setter=true
	name.chomp! "="
      else
	setter=false
      end
      
      if(!@pObject.hasAttr(name))
	raise NoMethodError.new(name)
      end

      
      args=RubyPyApi::PyObject.convert(*args)

      if(setter)
	return _setAttr(name,*args)
      end


      pFunc = @pObject.getAttr(name)
      
      if(pFunc.callable?)
	pTuple=RubyPyApi::PyObject.buildArgTuple(*args)
	pReturn = pFunc.callObject(pTuple)
	if(PythonError.error?)
	  rbType = RubyPyApi::PyObject.new nil
	  rbValue = RubyPyApi::PyObject.new nil
	  rbTraceback = RubyPyApi::PyObject.new nil

	  PythonError.fetch(rbType,rbValue,rbTraceback)

	  #Decrease the reference count. This will happen anyway when they go
	  #out of scope but might as well.
	  rbValue.xDecref
	  rbTraceback.xDecref
	  pyName = rbType.getAttr("__name__")

	  rbType.xDecref
	  rbName=pyName.rubify
	  pyName.xDecref
	  
	  PythonError.clear

	  raise PythonError.new(rbName)
	end
      else
	pReturn = pFunc
      end

      return _wrap(pReturn)
    end

    def rubify
      @pObject.rubify
    end
	
  end
end
