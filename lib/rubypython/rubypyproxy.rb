class RubyPyApi::NullPObjectError < RuntimeError
end

class RubyPyApi::RubyPyProxy

  attr_reader :pObject

  def initialize(pObject)
    @pObject = pObject
  end

  def method_missing(name, *args, &block)
    if(!@pObject.hasAttr(name.to_s))
      raise NoMethodError.new(name.to_s)
    end

    args.map! do |arg|
      if(arg.instance_of? RubyPyApi::PyObject)
        arg
      elsif(arg.instance_of?(RubyPyApi::RubyPyProxy))
        if(arg.pObject.null?)
          raise NullPObjectError.new("Null pObject pointer.")
        else
          arg.pObject
        end
      else
        RubyPyApi::PyObject.new(arg)
      end
    end

    pList = RubyPyApi::PyObject.newList(*args)
    pTuple = RubyPyApi::PyObject.makeTuple(pList)

    pFunc = @pObject.getAttr(name.to_s)

    pReturn = pFunc.callObject(pTuple)

    return RubyPyApi::RubyPyProxy.new(pReturn)
  end
      


end
