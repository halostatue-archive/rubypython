module RubyPython
  module Operators
    def self.operator_
      @@operator ||= RubyPython.import('operator')
    end

    def self.bin_op rname, pname
      define_method rname.to_sym do |other|
        self.__send__ pname, other
      end
    end

    def self.rel_op rname, pname
      define_method rname.to_sym do |other|
        Operators.operator_.__send__(pname, self, other).rubify
      end
    end


    [
      [:+, '__add__'],
      [:-, '__sub__'],
      [:*, '__mul__'],
      [:/, '__div__'],
      [:&, '__and__'],
      [:^, '__xor__'],
      [:%, '__mod__'],
      [:**, '__pow__'],
      [:>>, '__rshift__'],
      [:<<, '__lshift__']
    ].each do |args|
      bin_op *args
    end

    [
      [:==, 'eq'],
      [:<, 'lt'],
      [:<=, 'le'],
      [:>, 'gt'],
      [:>=, 'ge']
    ].each do |args|
      rel_op *args
    end

    def [](index)
      self.__getitem__ index
    end

    def []=(index, value)
      self.__setitem__ index, value
    end

  end
end
