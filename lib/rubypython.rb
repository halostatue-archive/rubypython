require 'rubypython_bridge.so'

# 
# This module provides the direct user interface for the RubyPython extension.
# 
# The majority of the functionality lies in the _RubyPythonBridge_ module, which is provided
# by the C extension. However, the end user should only worry about dealing with the RubyPython
# module as that is designed for user interaction.
#   
# It is important to remember that the Python Interpreter must be started before the bridge
# is functional. This may be done by two methods. One is to use the +start+ function.
# This will start the embedded interpreter. If this approach is used, the user should
# remember to call +RubyPython.stop+ when they are finished with python.
# Example:
#   RubyPython.start
#   CPickle=RubyPython.import "cPickle"
#   puts CPickle.dumps "RubyPython is awesome!"
#   RubyPython.stop
#   
# The other method is preferable if one wants a simpler approach. This other method is to use
# <tt>RubyPython.run</tt>. _run_ takes a block which is evaluated in the scope of the RubyPython module.
# In addition, the interpreter is started before the block is run and halted at its completion.
# This allows one to do something like the following:
#   RubyPython.run do
#     CPickle=import "cPickle"
#     puts CPickle.dumps "RubyPython is still awesome!"
#   end
# 
module RubyPython
  
  class RubyPythonBridge::RubyPyObject
    def inspect
      "<#{self.class}:  #{__name}>"
    end
  end
  
  # RubyPython.start
  # 
  # Used to started the python interpreter. Delegates to RubyPythonBridge
  # 
  #   RubyPython.start
  #   --Some python code--
  #   RubyPython.stop
  #   
  # Also see, _stop_
  def self.start() # true||false
    RubyPythonBridge.start
  end
  
  
  # RubyPython.stop
  # 
  # Used to end the python session. Adds some cleanup on top of RubyPythonBridge.stop
  def self.stop() #=> true,false
    ObjectSpace.each_object(RubyPythonBridge::RubyPyObject) do |o|
      o.free_pobj
    end
    RubyPythonBridge.stop
  end
  
  # RubyPython.import(modname)
  # 
  # Import the python module +modname+ and return it wrapped as a ruby object
  def self.import(mod)
    RubyPythonBridge.import(mod)
  end

end