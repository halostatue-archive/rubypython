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

    
    args=RubyPyApi.pythonifyObjects(*args)

    if(setter)
      return _setAttr(name,*args)
    end

    pTuple=RubyPyApi.buildArgTuple(*args)
    pFunc = @pObject.getAttr(name)

    pReturn = pFunc.callObject(pTuple)

    return RubyPyApi::RubyPyProxy.new(pReturn)
  end
      


end
