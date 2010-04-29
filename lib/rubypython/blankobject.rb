class RubyPyApi::BlankObject
  instance_methods.each do |m|
    undef_method m unless m =~/^__/
  end
end
