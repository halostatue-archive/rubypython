module RubyPyApi
  #An object to be used as a base class for Proxy classes.
  #It is necessary to define this because no such class exists in Ruby
  #1.8.x
  class BlankObject
    instance_methods.each do |m|
      undef_method m unless m =~/(^__)||object_id/
    end
  end
end
