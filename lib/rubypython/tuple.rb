module RubyPython
  # A subclass of ::Array that will convert to a Python Tuple automatically.
  class Tuple < ::Array
    def self.tuple(array)
      value = self.new
      value.replace(array.dup)
      value
    end
  end

  # A conversion method.
  def self.Tuple(array)
    ::RubyPython::Tuple.tuple(array)
  end
end
