require 'rubypython/blankobject'
require 'singleton'

module RubyPython
  # A singleton object providing access to the python \_\_main\_\_ and
  # \_\_builtin\_\_ modules.  This can be conveniently accessed through the
  # already instaniated PyMain constant.  The \_\_main\_\_ namespace is
  # searched before the \_\_builtin\_\_ namespace. As such, naming clashes will
  # be resolved in that order.
  #
  # ## Block Syntax
  # The PyMainClass object provides somewhat experimental block support.  A
  # block may be passed to a method call and the object returned by the
  # function call will be passed as an argument to the block.
  class PyMainClass < BlankObject
    include Singleton
    attr_writer :main, :builtin
    
    #@return [RubyPyModule] a proxy object wrapping the Python \__main\__
    #namespace.
    def main 
      @main||=RubyPython.import "__main__"
    end
    
    #@return [RubyPyModule] a proxy object wrapping the Python \__builtin\__
    #namespace.
    def builtin
      @builtin||=RubyPython.import "__builtin__"
    end

    #Delegates any method calls on this object to the Python \__main\__ or
    #\__builtin\__ namespaces. Method call resolution occurs in that order.
    def method_missing(name,*args,&block)
      proxy = if main.respond_to?(name)
                main
              elsif builtin.respond_to?(name)
                builtin
              else
                super(name, *args)
              end
      result = if proxy.is_real_method?(name)
                 proxy.__send__(name, *args)
               else
                 proxy.__send__(:method_missing, name,*args)
               end
      block ? block.call(result) : result
    end
  end

  PyMain = PyMainClass.instance
end
