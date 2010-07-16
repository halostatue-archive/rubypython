require 'ffi'
require 'rubypython/rubypyapi/python'

module RubyPyApi
  module Macros
    #attach_function :rpPy_mTrue, [], :pointer
    #attach_function :rpPy_mRETURN_TRUE, [], :pointer
    #attach_function :rpPy_mFalse, [], :pointer
    #attach_function :rpPy_mRETURN_FALSE, [], :pointer
    #attach_function :rpPy_mNone, [], :pointer

    #attach_function :rpPy_mXINCREF, [:pointer], :void
    #attach_function :rpPy_mXDECREF, [:pointer], :void


    #Useful Python Macros reimplemented in Ruby
    def self.mPy_TYPE(pObjPointer)
      pStruct = Python::PyObjectStruct.new pObjPointer
      pStruct[:ob_type]
    end

    def self.rpPyObject_mTypeCheck(pObject, pTypePointer)
      if mPy_TYPE(pObject) == pTypePointer
        1
      else
        0
      end
    end

    def self.rpPy_mTrue
      Python.Py_TrueStruct.to_ptr
    end

    def self.rpPy_mFalse
      Python.Py_ZeroStruct.to_ptr
    end

    def self.rpPy_mNone
      Python.Py_NoneStruct.to_ptr
    end

    def self.rpPy_mRETURN_FALSE
      rpPy_mXINCREF(rpPy_mFalse)
      rpPy_mFalse
    end

    def self.rpPy_mRETURN_TRUE
      rpPy_mXINCREF(rpPy_mTrue)
      rpPy_mTrue
    end

    def self.rpPy_mINCREF(pObject)
      pStruct = Python::PyObjectStruct.new pObject
      pStruct[:ob_refcnt] += 1
    end

    def self.rpPy_mDECREF(pObject)
      pStruct = Python::PyObjectStruct.new pObject
      pStruct[:ob_refcnt] -= 1
    end

    def self.rpPy_mXINCREF(pObject)
      if !pObject.null?
        rpPy_mINCREF pObject
      end
    end

    def self.rpPy_mXDECREF(pObject)
      if !pObject.null?
        rpPy_mDECREF pObject
      end
    end

  end
end
    
