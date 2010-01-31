class RubyPyApi::NullPObjectError < RuntimeError
end

class RubyPyApi::RubyPyProxy

  attr_reader :pObject

  def initialize(pObject)
    @pObject = pObject
  end

  def method_missing(name, *args, &block)
    if(!@pObject.hasAttr(name.to_s))
      raise NoMethodError
    end

    args.map! do |arg|
      if(arg.instance_of? RubyPyApi::PyObject)
        arg
      elsif(arg.instance_of?(RubyPyApi::RubyPyProxy))
        if(arg.null?)
          raise NullPObjectError("Null pObject pointer.")
        else
          arg.pObject
        end
             
      else
        RubyPyApi::PyObject.new(arg)
      end
    end

    pList = RubyPyApi::PyObject.newList(args)
    pTuple = RubyPyApi::PyObject.makeTuple(pList)

    pReturn = @pObject.callObject(pTuple)

    return RubyPyProxy.new(pReturn)
  end
      


end
