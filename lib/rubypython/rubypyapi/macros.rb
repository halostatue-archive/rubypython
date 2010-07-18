require 'ffi'
require 'rubypython/rubypyapi/python'

module RubyPyApi
  module Macros
    #Useful Python Macros reimplemented in Ruby
    def self.Py_TYPE(pObjPointer)
      pStruct = Python::PyObjectStruct.new pObjPointer
      pStruct[:ob_type]
    end

    def self.PyObject_TypeCheck(pObject, pTypePointer)
      if Py_TYPE(pObject) == pTypePointer
        1
      else
        0
      end
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
      Py_INCREF(Py_False)
      Py_False
    end

    def self.Py_RETURN_TRUE
      Py_INCREF(Py_True)
      Py_True
    end

    def self.Py_RETURN_NONE
      Py_INCREF(Py_None)
      Py_None
    end

    def self.Py_INCREF(pObject)
      pStruct = Python::PyObjectStruct.new pObject
      pStruct[:ob_refcnt] += 1
    end

    def self.Py_DECREF(pObject)
      pStruct = Python::PyObjectStruct.new pObject
      pStruct[:ob_refcnt] -= 1
    end

    def self.Py_XINCREF(pObject)
      if !pObject.null?
        Py_INCREF pObject
      end
    end

    def self.Py_XDECREF(pObject)
      if !pObject.null?
        Py_DECREF pObject
      end
    end

  end
end
    
