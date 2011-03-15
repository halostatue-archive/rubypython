require 'ffi'
require 'rubypython/python'

module RubyPython
  # Contains Python C API macros reimplmented in Ruby. For internal use only.
  module Macros
    def self.Py_REFCNT(pObjPointer)
      pStruct = Python::PyObjectStruct.new pObjPointer
      pStruct[:ob_refcnt]
    end

    def self.Py_TYPE(pObjPointer)
      pStruct = Python::PyObjectStruct.new pObjPointer
      pStruct[:ob_type]
    end

    # This has been modified from the C API macro to allow for multiple
    # pointer objects to be passed. It simplifies a number of checks.
    def self.PyObject_TypeCheck(pObject, pTypePointer)
      type = self.Py_TYPE(pObject)

      [ pTypePointer ].flatten.each do |pointer|
        if type == pointer
          return 1
        end
      end

      return 0
    end

    def self.Py_True
      Python.Py_TrueStruct.to_ptr
    end

    def self.Py_False
      Python.Py_ZeroStruct.to_ptr
    end

    def self.Py_None
      Python.Py_NoneStruct.to_ptr
    end

    def self.Py_RETURN_FALSE
      Python.Py_IncRef(self.Py_False)
      self.Py_False
    end

    def self.Py_RETURN_TRUE
      Python.Py_IncRef(self.Py_True)
      self.Py_True
    end

    def self.Py_RETURN_NONE
      Python.Py_IncRef(self.Py_None)
      self.Py_None
    end
  end
end
