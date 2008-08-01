require 'rubypython_bridge'

=begin
This module provides the direct user interface for the RubyPython extension.

The majority of the functionality lies in the _RubyPythonBridge_ module, which is provided
by the C extension. However, the end user should only worry about dealing with the RubyPython
module as that is designed for user interaction.
  
It is important to remember that the Python Interpreter must be started before the bridge
is functional. This may be done by two methods. One is to use the +start+ function.
This will start the embedded interpreter. If this approach is used, the user should
remember to call +RubyPython.stop+ when they are finished with python.
Example:
  RubyPython.start
  CPickle=RubyPython.import "cPickle"
  puts CPickle.dumps "RubyPython is awesome!"
  RubyPython.stop
  
The other method is preferable if one wants a simpler approach. This other method is to use
+RubyPython.run+. +run+ takes a block which is evaluated in the scope of the RubyPython module.
In addition, the interpreter is started before the block is run and halted at its completion.
This allows one to do something like the following:
  RubyPython.run do
    CPickle=import "cPickle"
    puts CPickle.dumps "RubyPython is still awesome!"
  end

=end
module RubyPython
  extend RubyPythonBridge
end