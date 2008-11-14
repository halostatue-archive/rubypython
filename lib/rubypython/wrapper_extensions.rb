require 'singleton'
class RubyPythonBridge::RubyPyObject
  def inspect
    "<#{self.class}:#{__name}>"
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
class PyMainClass < RubyPythonBridge::BlankObject
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
      result=main.send(name,*args)
    rescue NoMethodError
      begin
        result=builtin.send(name,*args)
      rescue NoMethodError
        super(name,*args)
      end
    end
    if(block)
      return block.call(result)
    end
    result
  end
end

# See _PyMainClass_
PyMain=PyMainClass.instance

# A wrapper class for Python Modules.
# 
# Methods calls are delegated to the equivalent Python methods/functions. Attribute references
# return either the equivalent attribute converted to a native Ruby type, or wrapped reference 
# to a Python object. RubyPyModule instances should be created through the use of RubyPython.import.
class RubyPythonBridge::RubyPyModule
  
end


# A wrapper class for Python classes.
# 
# This allows objects which cannot easily be converted to native Ruby types to still be accessible
# from within ruby. Most users need not concern themselves with anything about this class except
# its existence.
class RubyPythonBridge::RubyPyClass
  
end



# A wrapper class for Python functions and methods.
# 
# This is used internally to aid RubyPyClass in delegating method calls.
class RubyPythonBridge::RubyPyFunction
  
end

# A wrapper class for Python instances
class RubyPythonBridge::RubyPyInstance
  
end