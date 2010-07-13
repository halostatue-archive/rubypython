require 'ffi'

module RubyPyApi
  module Macros
    extend FFI::Library
    ffi_lib File.dirname(__FILE__) + '/../../../ext/rubypyapi/rubypyapi.bundle'
    attach_function :rpPyString_mCheck, [:pointer], :int
    attach_function :rpPyList_mCheck, [:pointer], :int
    attach_function :rpPyTuple_mCheck, [:pointer], :int
    attach_function :rpPyInt_mCheck, [:pointer], :int
    attach_function :rpPyLong_mCheck, [:pointer], :int
    attach_function :rpPyFloat_mCheck, [:pointer], :int
    attach_function :rpPyDict_mCheck, [:pointer], :int
    attach_function :rpPyObject_mTypeCheck, [:pointer, :pointer], :int

    attach_function :rpPy_mTrue, [], :pointer
    attach_function :rpPy_mRETURN_TRUE, [], :pointer
    attach_function :rpPy_mFalse, [], :pointer
    attach_function :rpPy_mRETURN_FALSE, [], :pointer
    attach_function :rpPy_mNone, [], :pointer

    attach_function :rpPy_mXINCREF, [:pointer], :void
    attach_function :rpPy_mXDECREF, [:pointer], :void

  end
end
    
