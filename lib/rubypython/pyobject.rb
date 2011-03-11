require 'rubypython/python'
require 'rubypython/macros'
require 'rubypython/conversion'
require 'ffi'

# This object is an opaque wrapper around the C PyObject\* type used by
# the python C API. This class **should not** be used by the end user.
# They should instead make use of the {RubyPyProxy} class and its
# subclasses.
class RubyPython::PyObject
  # @private
  #
  # This class wraps C PyObject\*s so that the RubyPython::Python reference count is
  # automatically decreased when the Ruby object referencing them goes out
  # of scope.
  class AutoPyPointer < FFI::AutoPointer
    class << self
      # Keeps track of which objects are associated with the currently
      # running RubyPython::Python interpreter, so that RubyPython knows not to try to
      # decrease the reference counts of the others when garbage
      # collecting.
      attr_accessor :current_pointers

      # When used along with the FFI Library method is executed whenever a
      # pointer is garbage collected so that cleanup can be done. In our
      # case we decrease the reference count of the held pointer as long
      # as the object is still good. There is really no reason the
      # end-user would need to the use this method directly.
      def release(pointer)
        obj_id = pointer.object_id
        if (RubyPython::Python.Py_IsInitialized != 0) and @current_pointers.delete(obj_id)
          RubyPython::Python.Py_DecRef pointer
        end
      end

      # Called by {RubyPython} when the interpreter is started or stopped so
      # that the neccesary preperation or cleanup can be done. For internal
      # use only.
      def update(status)
        case status
        when :stop
          current_pointers.clear if status.equal? :stop
        end
      end
    end

    self.current_pointers = {}
  end

  # The FFI::Pointer object which represents the RubyPython::Python PyObject\*.
  attr_reader :pointer

  # @param [FFI::Pointer, other] pointer objects passed in to the
  #     constructor are just assigned to the pointer attribute of the
  #     instance. All other objects are converted via
  #     {Conversion.rtopObject} before being assigned.
  def initialize(rObject)
    if rObject.kind_of? FFI::AutoPointer
      new_pointer = FFI::Pointer.new rObject
      @pointer = AutoPyPointer.new new_pointer
      xIncref
    elsif rObject.kind_of? FFI::Pointer
      @pointer = AutoPyPointer.new rObject
    else
      @pointer = AutoPyPointer.new RubyPython::Conversion.rtopObject(rObject)
    end
    AutoPyPointer.current_pointers[@pointer.object_id] = true
  end

  # Attempts to convert the wrapped object to a native ruby type.
  # @return a ruby version of the wrapped object
  def rubify
    RubyPython::Conversion.ptorObject @pointer
  end

  # Tests whether the wrapped object has a given attribute
  # @param [String] the name of the attribute to look up
  # @return [Boolean]
  def hasAttr(attrName)
    RubyPython::Python.PyObject_HasAttrString(@pointer, attrName) == 1
  end

  # Retrieves an object from the wrapped python object
  # @param [String] the name of attribute to fetch
  # @return [PyObject] a Ruby wrapper around the fetched attribute
  def getAttr(attrName)
    pyAttr = RubyPython::Python.PyObject_GetAttrString @pointer, attrName
    self.class.new pyAttr
  end

  # Sets the an attribute of the wrapped RubyPython::Python object
  # @param [String] attrName the name of of attribute to set
  # @param [PyObject] rbPyAttr a {PyObject} wrapper around the value we
  # wish to set the attribute to.
  # @return [Boolean] returns true if the attribute is sucessfully set.
  def setAttr(attrName, rbPyAttr)
    RubyPython::Python.PyObject_SetAttrString(@pointer, attrName, rbPyAttr.pointer) != -1
  end

  # Calls the wrapped RubyPython::Python object with the supplied arguments.
  # @param [PyObject] rbPyArgs a {PyObject} wrapping a tuple of the
  # supplied arguments
  # @param [PyObject] rbPyKeywords a {PyObject} wrapping keyword arguments.
  # @return [PyObject] a {PyObject} wrapper around the returned object
  # (this may be NULL).
  def callObjectKeywords(rbPyArgs, rbPyKeywords)
    pyReturn = RubyPython::Python.PyObject_Call(@pointer, rbPyArgs.pointer, rbPyKeywords.pointer)
    self.class.new pyReturn
  end

  # Calls the wrapped RubyPython::Python object with the supplied arguments.
  # @param [PyObject] rbPyArgs a {PyObject} wrapping a tuple of the
  # supplied arguments
  # @return [PyObject] a {PyObject} wrapper around the returned object
  # (this may be NULL).
  def callObject(rbPyArgs)
    pyReturn = RubyPython::Python.PyObject_CallObject(@pointer, rbPyArgs.pointer)
    self.class.new pyReturn
  end

  # Decrease the reference count of the wrapped object
  # @return [void]
  def xDecref
    AutoPyPointer.release(@pointer)
    @pointer.free
  end

  # Increase the reference count of the wrapped object
  # @return [void]
  def xIncref
    RubyPython::Python.Py_IncRef @pointer
  end

  # Tests whether the wrapped object is NULL.
  def null?
    @pointer.null?
  end

  # @return [Number]
  def cmp(other)
    RubyPython::Python.PyObject_Compare @pointer, other.pointer
  end

  # Tests whether the wrapped object is a function or a method. This is
  # not the same as {#callable?} as many other RubyPython::Python objects are
  # callable.
  def function_or_method?
    check = RubyPython::Macros.PyObject_TypeCheck(@pointer, [
                                            RubyPython::Python.PyFunction_Type.to_ptr,
                                            RubyPython::Python.PyCFunction_Type.to_ptr,
                                            RubyPython::Python.PyMethod_Type.to_ptr
    ])
    check != 0
  end

  # Is the wrapped object callable?
  def callable?
    RubyPython::Python.PyCallable_Check(@pointer) != 0
  end

  # Returns the 'directory' of the RubyPython::Python object; similar to #methods in
  # Ruby.
  def dir
    return self.class.new(RubyPython::Python.PyObject_Dir(@pointer)).rubify.map do |x|
      x.to_sym
    end
  end

  # Tests whether the wrapped object is a RubyPython::Python class (both new and old
  # style).
  def class?
    isClassObj = (RubyPython::Macros.PyObject_TypeCheck(@pointer, RubyPython::Python.PyClass_Type.to_ptr) == 1)
    isTypeObj = (RubyPython::Macros.PyObject_TypeCheck(@pointer, RubyPython::Python.PyType_Type.to_ptr) == 1)
    isTypeObj or isClassObj
  end

  # Manipulates the supplied {PyObject} instance such that it is suitable
  # to passed to {#callObject}. If `rbObject` is a tuple then the argument
  # passed in is returned. If it is a list then the list is converted to a
  # tuple. Otherwise returns a tuple with one element: `rbObject`.
  # @param [PyObject] rbObject the argment to be turned into a tuple.
  # @return [PyObject<tuple>]
  def self.makeTuple(rbObject)
    pTuple = nil

    if RubyPython::Macros.PyObject_TypeCheck(rbObject.pointer, RubyPython::Python.PyList_Type.to_ptr) != 0
      pTuple = RubyPython::Python.PySequence_Tuple(rbObject.pointer)
    elsif RubyPython::Macros.PyObject_TypeCheck(rbObject.pointer, RubyPython::Python.PyTuple_Type.to_ptr) != 0
      pTuple = rbObject.pointer
    else
      pTuple = RubyPython::Python.PyTuple_Pack(1, :pointer, rbObject.pointer)
    end

    self.new pTuple
  end

  # Wraps up the supplied arguments in RubyPython::Python list.
  # @return [PyObject<list>]
  def self.newList(*args)
    rbList = self.new RubyPython::Python.PyList_New(args.length)

    args.each_with_index do |el, i|
      RubyPython::Python.PyList_SetItem rbList.pointer, i, el.pointer
    end

    rbList
  end

  # Converts the supplied arguments to PyObject instances.
  # @return [Array<PyObject>]
  def self.convert(*args)
    args.map! do |arg|
      if arg.kind_of? RubyPython::PyObject
        arg
      elsif arg.kind_of? RubyPython::RubyPyProxy
        arg.pObject
      else
        RubyPython::PyObject.new arg
      end
    end
  end

  # Takes an array of wrapped RubyPython::Python objects and wraps them in a tuple
  # such that they may be passed to {#callObject}.
  # @param [Array<PyObject>] args the arguments to be inserted into the
  # tuple.
  # @return [PyObject<tuple>]
  def self.buildArgTuple(*args)
    pList = RubyPython::PyObject.newList(*args)
    pTuple = RubyPython::PyObject.makeTuple(pList)
    pList.xDecref
    pTuple
  end
end
