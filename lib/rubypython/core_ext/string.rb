class String
  #This is necessary for Ruby versions 1.8.6 and below as 
  #String#end_with? is not defined in this case.
  def end_with?(c)
    self[-1].chr == c
  end
end unless String.respond_to? :end_with?
