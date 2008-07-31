class PythonModule
  def initialize(name)
    @name=name
  end
  def method_missing(func,*args)
    RubyPython.func_with_module(@name,func.to_s,*args)
  end
end