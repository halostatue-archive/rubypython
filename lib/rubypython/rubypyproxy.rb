class RubyPyApi::RubyPyProxy

  def initialize(pObject)
    @pObject = pObejct
  end

  def method_missing(name, *args, &block)
    if(!@pObject.hasAttr(name.to_s))
      raise NoMethodError
    end

    args.map! do |arg|
      if(arg.instance_of? RubyPyApi::PyObject)
        arg
      else
        RubyPyApi::PyObject.new(arg)
    end

      
      
  end

end
