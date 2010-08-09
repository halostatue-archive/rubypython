module RubyPython
  module Operators

    def ==(other)
      @pObject.cmp(other.pObject) == 0
    end

    def +(other)
      self.__add__ other
    end

    def -(other)
      self.__sub__ other
    end

    def *(other)
      self.__mul__ other
    end

    def /(other)
      self.__div__ other
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

  end
end
