# A mixin module to provide method delegation to a proxy class. This is done
# either by delegating to methods defined on the wrapped object or by using
# the \Python _operator_ module. A large number of the methods are
# dynamically generated and so their documentation is not provided here. In
# general all operators that can be overloaded are delegated.
module RubyPython::Operators
  # Provides access to the \Python _operator_ module.
  def self.operator_
    @@operator ||= RubyPython.import('operator')
  end

  # Creates a method to delegate a binary operation.
  # [rname] The name of the Ruby method for this operation. Can be either a
  # Symbol or a String.
  # [pname] The name of the \Python magic method to which this method should
  # be delegated.
  def self.bin_op(rname, pname)
    define_method rname.to_sym do |other|
      self.__send__(pname, other)
    end
  end

  # Creates a method to delegate a relational operator. The result of the
  # delegated method will always be converted to a Ruby type so that simple
  # boolean testing may occur. These methods are implemented with calls the
  # _operator_ module.
  #
  # [rname] The name of the Ruby method for this operation. Can be a Symbol
  # or a String.
  # [pname] The name of the \Python magic method to which this method should
  # be delegated.
  def self.rel_op(rname, pname)
    define_method rname.to_sym do |other|
      RubyPython::Operators.operator_.__send__(pname, self, other).rubify
    end
  end

  # Creates a method to delegate a relational operator. 
  # These methods are implemented with calls the _operator_ module.
  # [rname] The name of the Ruby method for this operation. Can be a Symbol
  # or a String.
  # [pname] The name of the \Python magic method to which this method should
  # be delegated.
  def self.unary_op(rname, pname)
    define_method rname.to_sym do
      RubyPython::Operators.operator_.__send__(pname, self)
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
    [:<<, '__lshift__'],
    [:|, '__or__']
  ].each do |args|
    bin_op *args
  end

  [
    [:~, :__invert__],
    [:+@, :__pos__],
    [:-@, :__neg__]
  ].each do |args|
    unary_op *args
  end

  [
    [:==, 'eq'],
    [:<, 'lt'],
    [:<=, 'le'],
    [:>, 'gt'],
    [:>=, 'ge'],
    [:equal?, 'is_']
  ].each do |args|
    rel_op *args
  end

  # Delegates object indexed access to the wrapped \Python object.
  def [](index)
    self.__getitem__ index
  end

  # Delegates setting of various indices to the wrapped \Python object.
  def []=(index, value)
    self.__setitem__ index, value
  end

  # Delegates membership testing to \Python.
  def include?(item)
    self.__contains__(item).rubify
  end

  # Delegates Comparison to \Python.
  def <=>(other)
    RubyPython::PyMain.cmp(self, other)
  end

  class << self
    # Called by RubyPython when the interpreter is started or stopped so
    # that the necessary preparation or cleanup can be done. For internal
    # use only.
    def python_interpreter_update(status)
      case status
      when :stop
        @@operator = nil
      end
    end
    private :python_interpreter_update
  end

  # Aliases eql? to == for Python objects.
  alias_method :eql?, :==
end
