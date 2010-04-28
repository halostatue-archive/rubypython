class RubyPyApi::NullPObjectError < RuntimeError
end

class RubyPyApi::RubyPyProxy

  attr_reader :pObject

  def initialize(pObject)
    @pObject = pObject
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
    else
      pReturn = pFunc
    end

    return _wrap(pReturn)
  end
      
end
