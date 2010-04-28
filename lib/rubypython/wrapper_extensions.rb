#This object is an opaque wrapper around the C PyObject* type used by the python
#C API. This class <em>should not</em> be used by the end user. They should instead
#make use of the RubyPyApi::RubyPyProxy class and its subclasses.
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
