require 'ffi'

module RubyPyApi
  module Macros
    extend FFI::Library
    ffi_lib File.dirname(__FILE__) + '/../../../ext/rubypyapi/rubypyapi.bundle'

    attach_function :rpPyCallable_mCheck, [:pointer], :int
    #attach_function :rpPyObject_mTypeCheck, [:pointer, :pointer], :int

    attach_function :rpPy_mTrue, [], :pointer
    attach_function :rpPy_mRETURN_TRUE, [], :pointer
    attach_function :rpPy_mFalse, [], :pointer
    attach_function :rpPy_mRETURN_FALSE, [], :pointer
    attach_function :rpPy_mNone, [], :pointer

    attach_function :rpPy_mXINCREF, [:pointer], :void
    attach_function :rpPy_mXDECREF, [:pointer], :void


    #Useful Python Macros reimplemented in Ruby
    def self.mPy_TYPE(pObjPointer)
      pStruct = Python::PyObjectStruct.new pObjPointer
      pStruct.read_pointer
    end

    def self.rpPyObject_mTypeCheck(pObject, pTypePointer)
      if mPy_TYPE(pObject) == pTypePointer
        1
      else
        0
      end
    end
  end
end
    
