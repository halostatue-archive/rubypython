require 'rubypython_bridge.so'
require 'rubypython/wrapper_extensions'


=begin rdoc
This module provides the direct user interface for the RubyPython extension.

The majority of the functionality lies in the _RubyPythonBridge_ module, which is provided
by the C extension. However, the end user should only worry about dealing with the RubyPython
module as that is designed for user interaction. Furthermore the RubyPythonBridge is somewhat
bad with memory management and using it directly may result in some strange crashes.

==Usage  
It is important to remember that the Python Interpreter must be started before the bridge
is functional. This may be done by two methods. One is to use the +start+ function.
This will start the embedded interpreter. If this approach is used, the user should
remember to call RubyPython.stop when they are finished with Python.
Example:
  RubyPython.start
  cPickle=RubyPython.import "cPickle"
  puts cPickle.dumps "RubyPython is awesome!"
  RubyPython.stop
  
The other method is preferable if one wants a simpler approach. This other method is to use
<tt>RubyPython.run</tt>. run takes a block which is evaluated in the scope of the RubyPython module.
In addition, the interpreter is started before the block is run and halted at its completion.
This allows one to do something like the following:
  RubyPython.run do
    cPickle=import "cPickle"
    puts cPickle.dumps "RubyPython is still awesome!"
  end

==Errors
The RubyPythonModule defines a new error object, PythonError. Should any error occur within
the Python interpreter, the class and value of the error will be passed back into ruby within
the text of the raised PythonError.
  irb(main):001:0> RubyPython.start
  => true
  irb(main):002:0> RubyPython.import "does not exist"
  PythonError: ImportError:(No module named does not exist)

  	from ./rubypython.rb:66:in `initialize'
  	from ./rubypython.rb:66:in `import'
  	from ./rubypython.rb:66:in `import'
  	from (irb):2
=end
module RubyPython
  
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
  
  

  # Used to end the python session. Adds some cleanup on top of RubyPythonBridge.stop
  def self.stop() #=> true,false
    ObjectSpace.each_object(RubyPythonBridge::RubyPyObject) do |o|
      o.free_pobj
    end
    PyMain.main=nil
    PyMain.builtin=nil
    RubyPythonBridge.stop
  end
  
  # Import the python module +mod+ and return it wrapped as a ruby object
  def self.import(mod)
    RubyPythonBridge.import(mod)
  end
  
  # Handles the setup and cleanup involved with using the interpreter for you.
  # Note that all Python object will be effectively scope to within the block
  # as the embedded interpreter will be halted at its end.
  def self.run(&block)
    start
      module_eval(&block)
    stop
  end

end


