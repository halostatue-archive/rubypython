class RubyPythonBridge::RubyPyObject
  def inspect
    "<#{self.class}:#{__name}>"
  end
end


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