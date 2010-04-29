class PythonError
  def self.handleError
    if(!error?)
      return Qnil
    end
    return new "err"
  end
end
