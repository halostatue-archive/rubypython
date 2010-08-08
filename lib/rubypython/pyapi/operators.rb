module RubyPython
  module PyAPI
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
          
    end
  end
end
