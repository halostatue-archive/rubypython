module RubyPython
  module Operators

    def self.bin_op rname, pname
      define_method rname.to_sym do |other|
        self.__send__ pname, other
      end
    end

    def ==(other)
      @pObject.cmp(other.pObject) == 0
    end

    [
      [:+, '__add__'],
      [:-, '__sub__'],
      [:*, '__mul__'],
      [:/, '__div__']
    ].each do |args|
      bin_op *args
    end

    def <(other)
      @pObject.cmp(other.pObject) < 0
    end

    def >(other)
      @pObject.cmp(other.pObject) > 0
    end

    def >=(other)
      (self > other) or (self == other)
    end

    def <=(other)
      (self < other) or (self == other)
    end

    def [](index)
      self.__getitem__ index
    end

    def []=(index, value)
      self.__setitem__ index, value
    end

  end
end
