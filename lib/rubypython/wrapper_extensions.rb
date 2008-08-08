require 'singleton'
class RubyPythonBridge::RubyPyObject
  def inspect
    "<#{self.class}:#{__name}>"
  end
end

class PyMainClass
  include Singleton
  def main
    @main||=RubyPython.import "__main__"
  end
  
  def builtin
    @builtin||=RubyPython.import "__builtin__"
  end
  
  def method_missing(name,*args,&block)
    begin
      main.send(name,*args)
    rescue NoMethodError
      begin
        builtin.send(name,*args)
      rescue NoMethodError
        super(name,*args)
      end
    end
  end
end

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