require 'ffi'
require 'open3'

module RubyPyApi
  module Python
    extend FFI::Library
    PYTHON_VERSION = Open3.popen3("python --version") { |i,o,e| e.read}.chomp.split[1].to_f
    PYTHON_NAME = "python#{PYTHON_VERSION}"
    LIB_NAME = "lib#{PYTHON_NAME}"
    LIB_EXT = "dylib"
    LIB = `python-config --prefix`.chomp +
     "/lib/#{PYTHON_NAME}/config/#{LIB_NAME}.#{LIB_EXT}"
    ffi_lib LIB

    #Python interpreter startup and shutdown
    attach_function :Py_IsInitialized, [], :int
    attach_function :Py_Initialize, [], :void
    attach_function :Py_Finalize, [], :void

    ###Python To Ruby Conversion

    #String Conversion
    attach_function :PyString_AsString, [:pointer], :string

    #List Conversion
    attach_function :PyList_GetItem, [:pointer, :int], :pointer

    #Integer Conversion
    attach_function :PyInt_AsLong, [:pointer], :long

    attach_function :PyLong_AsLong, [:pointer], :long

    #Float Conversion
    attach_function :PySequence_List, [:pointer], :pointer

    #Dict/Hash Conversion
    attach_function :PyDict_Next, [:pointer, :pointer, :pointer, :pointer], :int

    #Type Check

  end
end
