module RubyPyApi
  class BlankObject
    instance_methods.each do |m|
      undef_method m unless m =~/(^__)||object_id/
    end
  end
end
