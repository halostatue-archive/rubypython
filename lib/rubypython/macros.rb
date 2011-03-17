require 'ffi'
require 'rubypython/python'

# Contains Python C API macros reimplemented in Ruby. For internal use only.
module RubyPython::Macros #:nodoc:
  # Returns the reference count for the provided pointer.
  def self.Py_REFCNT(pObjPointer)
    pStruct = RubyPython::Python::PyObjectStruct.new pObjPointer
    pStruct[:ob_refcnt]
  end

  # Returns the object type for the provided pointer.
  def self.Py_TYPE(pObjPointer)
    pStruct = RubyPython::Python::PyObjectStruct.new pObjPointer
    pStruct[:ob_type]
  end

  # This has been modified from the C API macro to allow for multiple
  # pointer objects to be passed. It simplifies a number of checks.
  def self.PyObject_TypeCheck(pObject, pTypePointer)
    type = self.Py_TYPE(pObject)

    [ pTypePointer ].flatten.each do |pointer|
      return 1 if type == pointer
    end

    return 0
  end

  def self.Py_True
    RubyPython::Python.Py_TrueStruct.to_ptr
  end

  def self.Py_False
    RubyPython::Python.Py_ZeroStruct.to_ptr
  end

  def self.Py_None
    RubyPython::Python.Py_NoneStruct.to_ptr
  end

  def self.Py_RETURN_FALSE
    RubyPython::Python.Py_IncRef(self.Py_False)
    self.Py_False
  end

  def self.Py_RETURN_TRUE
    RubyPython::Python.Py_IncRef(self.Py_True)
    self.Py_True
  end

  def self.Py_RETURN_NONE
    RubyPython::Python.Py_IncRef(self.Py_None)
    self.Py_None
  end
end
