class RubyPyApi::PyObject
  def self.convert(*args)
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
  end

  def self.buildArgTuple(*args)
    pList = RubyPyApi::PyObject.newList(*args)
    RubyPyApi::PyObject.makeTuple(pList)
  end

end
