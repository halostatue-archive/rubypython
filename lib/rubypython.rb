require 'rubypython/wrapper_extensions'


=begin rdoc
This module provides the direct user interface for the RubyPython extension.

The majority of the functionality lies in the _RubyPyApi_ module, which is provided
by the C extension. However, the end user should only worry about dealing with the RubyPython
module as that is designed for user interaction.

==Usage  
It is important to remember that the Python Interpreter must be started before the bridge
is functional. 
This will start the embedded interpreter. If this approach is used, the user should
remember to call RubyPython.stop when they are finished with Python.
Example:
  RubyPython.start
  cPickle=RubyPython.import "cPickle"
  puts cPickle.dumps "RubyPython is awesome!"
  RubyPython.stop
=end
module RubyPython
end


