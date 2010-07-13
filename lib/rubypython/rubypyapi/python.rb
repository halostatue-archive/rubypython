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

    #String Methods
    attach_function :PyString_AsString, [:pointer], :string
    attach_function :PyString_FromString, [:string], :pointer

    #List Methods
    attach_function :PyList_GetItem, [:pointer, :int], :pointer
    attach_function :PyList_Size, [:pointer], :int
    attach_function :PyList_New, [:int], :pointer
    attach_function :PyList_SetItem, [:pointer, :int, :pointer], :void

    #Integer Methods
    attach_function :PyInt_AsLong, [:pointer], :long
    attach_function :PyInt_FromLong, [:long], :pointer

    attach_function :PyLong_AsLong, [:pointer], :long
    attach_function :PyLong_FromLong, [:pointer], :long

    #Float Methods
    attach_function :PyFloat_AsDouble, [:pointer], :double
    attach_function :PyFloat_FromDouble, [:double], :pointer

    #Tuple Methods
    attach_function :PySequence_List, [:pointer], :pointer
    attach_function :PySequence_Tuple, [:pointer], :pointer

    #Dict/Hash Methods
    attach_function :PyDict_Next, [:pointer, :pointer, :pointer, :pointer], :int
    attach_function :PyDict_New, [], :pointer
    attach_function :PyDict_SetItem, [:pointer, :pointer, :pointer], :int
    attach_function :PyDict_Contains, [:pointer, :pointer], :int
    attach_function :PyDict_GetItem, [:pointer, :pointer], :pointer

    #Type Objects
    attach_variable :PyString_Type, :pointer
    attach_variable :PyList_Type, :pointer
    attach_variable :PyInt_Type, :pointer
    attach_variable :PyLong_Type, :pointer
    attach_variable :PyFloat_Type, :pointer
    attach_variable :PyTuple_Type, :pointer
    attach_variable :PyDict_Type, :pointer
  end
end
