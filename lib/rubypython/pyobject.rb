require 'rubypython/python'
require 'rubypython/macros'
require 'rubypython/conversion'
require 'ffi'

# This object is an opaque wrapper around the C Py…Object types used by the
# \Python C API.
#
# This class is *only* for RubyPython internal use.
class RubyPython::PyObject # :nodoc: all
  # This class wraps C <tt>Py…Object</tt>s so that the RubyPython::Python
  # reference count is automatically decreased when the Ruby object
  # referencing them goes out of scope.
  class AutoPyPointer < ::FFI::AutoPointer # :nodoc:
    class << self
      # Keeps track of which objects are associated with the currently
      # running RubyPython::Python interpreter, so that RubyPython knows not
      # to try to decrease the reference counts of the others when garbage
      # collecting.
      attr_accessor :current_pointers

      # When used along with the FFI Library method is executed whenever a
      # pointer is garbage collected so that cleanup can be done. In our
      # case we decrease the reference count of the held pointer as long as
      # the object is still good. There is really no reason the end-user
      # would need to the use this method directly.
      def release(pointer)
        obj_id = pointer.object_id
        deleted = @current_pointers.delete(obj_id)
        if pointer.null?
          puts "Warning: Trying to DecRef NULL pointer" if RubyPython::Python.Py_IsInitialized != 0
        end
        if deleted and (RubyPython::Python.Py_IsInitialized != 0)
          RubyPython::Python.Py_DecRef pointer
        end
      end

      # Called by RubyPython when the interpreter is started or stopped so
      # that the necessary preparation or cleanup can be done. For internal
      # use only.
      def python_interpreter_update(status)
        case status
        when :stop
          current_pointers.clear
        end
      end
      private :python_interpreter_update
    end

    self.current_pointers = {}
  end

  # The AutoPyPointer object which represents the RubyPython::Python
  # Py…Object.
  attr_reader :pointer

  # [rObject] FFI Pointer objects passed into the constructor are wrapped in
  # an AutoPyPointer and assigned to the +#pointer+ attribute. Other objects
  # are converted, if possible, from their Ruby types to their \Python types
  # and wrapped in an AutoPyPointer. The conversion is done with
  # +RubyPython::Conversion.rtopObject+.
  def initialize(rObject)
    if rObject.kind_of? ::FFI::AutoPointer
      new_pointer = ::FFI::Pointer.new rObject
      @pointer = AutoPyPointer.new new_pointer
      xIncref
    elsif rObject.kind_of? ::FFI::Pointer
      @pointer = AutoPyPointer.new rObject
    else
      @pointer = AutoPyPointer.new RubyPython::Conversion.rtopObject(rObject)
    end
    AutoPyPointer.current_pointers[@pointer.object_id] = true
  end

  # Attempts to convert the wrapped object to a native ruby type. Returns
  # either the Ruby object or the unmodified \Python object.
  def rubify
    RubyPython::Conversion.ptorObject @pointer
  end

  # Tests whether the wrapped \Python object has a given attribute. Returns
  # +true+ if the attribute exists.
  # [attrName] The name of the attribute to look up.
  def hasAttr(attrName)
    RubyPython::Python.PyObject_HasAttrString(@pointer, attrName) == 1
  end

  # Retrieves an object from the wrapped \Python object.
  # [attrName] The name of the attribute to fetch.
  def getAttr(attrName)
    pyAttr = RubyPython::Python.PyObject_GetAttrString(@pointer, attrName)
    self.class.new pyAttr
  end

  # Sets an attribute of the wrapped \Python object. Returns +true+ if the
  # attribute was successfully set.
  # [attrName] The name of the attribute to set.
  # [rbPyAttr] A PyObject wrapper around the value that we wish to set the
  # attribute to.
  def setAttr(attrName, rbPyAttr)
    #SetAttrString should incref whatever gets passed to it.
    RubyPython::Python.PyObject_SetAttrString(@pointer, attrName, rbPyAttr.pointer) != -1
  end

  # Calls the wrapped \Python object with the supplied arguments and keyword
  # arguments. Returns a PyObject wrapper around the returned object, which
  # may be +NULL+.
  # [rbPyArgs]      A PyObject wrapping a Tuple of the supplied arguments.
  # [rbPyKeywords]  A PyObject wrapping a Dict of keyword arguments.
  def callObjectKeywords(rbPyArgs, rbPyKeywords)
    pyReturn = RubyPython::Python.PyObject_Call(@pointer, rbPyArgs.pointer, rbPyKeywords.pointer)
    self.class.new pyReturn
  end

  # Calls the wrapped \Python object with the supplied arguments. Returns a
  # PyObject wrapper around the returned object, which may be +NULL+.
  # [rbPyArgs]  A PyObject wrapping a Tuple of the supplied arguments.
  def callObject(rbPyArgs)
    pyReturn = RubyPython::Python.PyObject_CallObject(@pointer, rbPyArgs.pointer)
    self.class.new pyReturn
  end

  # Decrease the reference count of the wrapped object.
  def xDecref
    AutoPyPointer.release(@pointer)
    @pointer = nil
  end

  # Increase the reference count of the wrapped object
  def xIncref
    RubyPython::Python.Py_IncRef @pointer
    nil
  end

  # Tests whether the wrapped object is +NULL+.
  def null?
    @pointer.null?
  end

  # Performs a compare on two Python objects. Returns a value similar to
  # that of the spaceship operator (<=>).
  def cmp(other)
    RubyPython::Python.PyObject_Compare @pointer, other.pointer
  end

  # Tests whether the wrapped object is a function or a method. This is not
  # the same as #callable? as many other \Python objects are callable.
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

  # Tests whether the wrapped object is a RubyPython::Python class (both new
  # and old style).
  def class?
    check = RubyPython::Macros.PyObject_TypeCheck(@pointer, [
                                                  RubyPython::Python.PyClass_Type.to_ptr,
                                                  RubyPython::Python.PyType_Type.to_ptr
    ])
    check != 0
  end


  # Converts the supplied arguments to PyObject instances.
  def self.convert(*args)
    args.map do |arg|
      if arg.kind_of? RubyPython::PyObject
        arg
      elsif arg.kind_of? RubyPython::RubyPyProxy
        arg.pObject
      else
        RubyPython::PyObject.new arg
      end
    end
  end

  # Takes an array of wrapped \Python objects and wraps them in a Tuple such
  # that they may be passed to #callObject.
  # [args] An array of PyObjects; the arguments to be inserted into the
  # Tuple.
  def self.buildArgTuple(*args)
    self.new RubyPython::Conversion.rtopArrayToTuple(args)
  end
end
