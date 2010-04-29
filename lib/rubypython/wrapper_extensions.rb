require 'rubypython/blankobject'
require 'singleton'

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

# A singleton object providing access to the python __main__ and __builtin__ modules.
# This can be conveniently accessed through the already instaniated PyMain constant.
# The __main__ namespace is searched beofre the __builtin__ namespace. As such,
# naming clashes will be resolved in that order.
#
# == Block Syntax
# The PyMainClass object provides somewhat experimental block support.
# A block may be passed to a method call and the object returned by the function call
# will be passed as an argument to the block.
class PyMainClass < RubyPyApi::BlankObject
  include Singleton
  attr_writer :main, :builtin
  #:nodoc:
  def main
    @main||=RubyPython.import "__main__"
  end
  
  #:nodoc:
  def builtin
    @builtin||=RubyPython.import "__builtin__"
  end
  
  #:nodoc:
  def method_missing(name,*args,&block)
    begin
      result=main.__send__(name,*args)
    rescue NoMethodError
      begin
        result=builtin.__send__(name,*args)
      rescue NoMethodError
        super(name,*args)
      end
    end
    if(block)
      return block.call(result)
    end
    return result
  end
end

# See _PyMainClass_
PyMain=PyMainClass.instance
