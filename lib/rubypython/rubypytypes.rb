class RubyPython::RubyPyClass < RubyPyApi::RubyPyProxy
  def new(*args)
    pTuple=RubyPyApi::PyObject.buildArgTuple(*args)
    pNew=@pObject.callObject(pTuple)

    #TODO: Dynamically determine type to return here.
    RubyPyApi::RubyPyProxy.new pNew
  end
end
