require 'ffi'
require 'open3'

module RubyPython
  #This module provides access to the Python C API functions via the Ruby ffi
  #gem. Documentation for these functions may be found [here](http://docs.python.org/c-api/). Likewise the FFI gem documentation may be found [here](http://rdoc.info/projects/ffi/ffi).
  module Python
    extend FFI::Library
    PYTHON_VERSION = Open3.popen3("python --version") { |i,o,e| e.read}.chomp.split[1].to_f
    PYTHON_NAME = "python#{PYTHON_VERSION}"
    LIB_NAME = "lib#{PYTHON_NAME}"
    LIB_EXT = FFI::Platform::LIBSUFFIX
    LIB = File.join(`python -c "import sys; print(sys.prefix)"`.chomp,
      "lib", "#{PYTHON_NAME}", "config", "#{LIB_NAME}.#{LIB_EXT}")
    @ffi_libs = [FFI::DynamicLibrary.open(LIB, FFI::DynamicLibrary::RTLD_LAZY|FFI::DynamicLibrary::RTLD_GLOBAL)]

    #The class is a little bit of a hack to extract the address of global
    #structs. If someone knows a better way please let me know.
    class DummyStruct < FFI::Struct
      layout :dummy_var, :int
    end

    #Python interpreter startup and shutdown
    attach_function :Py_IsInitialized, [], :int
    attach_function :Py_Initialize, [], :void
    attach_function :Py_Finalize, [], :void

    #Module methods
    attach_function :PyImport_ImportModule, [:string], :pointer

    #Object Methods
    attach_function :PyObject_HasAttrString, [:pointer, :string], :int
    attach_function :PyObject_GetAttrString, [:pointer, :string], :pointer
    attach_function :PyObject_SetAttrString, [:pointer, :string, :pointer], :int

    attach_function :PyObject_Compare, [:pointer, :pointer], :int

    attach_function :PyObject_CallObject, [:pointer, :pointer], :pointer
    attach_function :PyCallable_Check, [:pointer], :int

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
    attach_function :PyTuple_Pack, [:int, :varargs], :pointer

    #Dict/Hash Methods
    attach_function :PyDict_Next, [:pointer, :pointer, :pointer, :pointer], :int
    attach_function :PyDict_New, [], :pointer
    attach_function :PyDict_SetItem, [:pointer, :pointer, :pointer], :int
    attach_function :PyDict_Contains, [:pointer, :pointer], :int
    attach_function :PyDict_GetItem, [:pointer, :pointer], :pointer

    #Error Methods
    attach_function :PyErr_Fetch, [:pointer, :pointer, :pointer], :void
    attach_function :PyErr_Occurred, [], :pointer
    attach_function :PyErr_Clear, [], :void

    #Reference Counting
    attach_function :Py_IncRef, [:pointer], :void
    attach_function :Py_DecRef, [:pointer], :void

    #Type Objects
    attach_variable :PyString_Type, DummyStruct.by_value
    attach_variable :PyList_Type, DummyStruct.by_value
    attach_variable :PyInt_Type, DummyStruct.by_value
    attach_variable :PyLong_Type, DummyStruct.by_value
    attach_variable :PyFloat_Type, DummyStruct.by_value
    attach_variable :PyTuple_Type, DummyStruct.by_value
    attach_variable :PyDict_Type, DummyStruct.by_value
    attach_variable :PyFunction_Type, DummyStruct.by_value
    attach_variable :PyMethod_Type, DummyStruct.by_value
    attach_variable :PyType_Type, DummyStruct.by_value
    attach_variable :PyClass_Type, DummyStruct.by_value

    attach_variable :Py_TrueStruct, :_Py_TrueStruct, DummyStruct.by_value
    attach_variable :Py_ZeroStruct, :_Py_ZeroStruct, DummyStruct.by_value
    attach_variable :Py_NoneStruct, :_Py_NoneStruct, DummyStruct.by_value

    #This is an implementation of the basic structure of a Python PyObject
    #struct. The C struct is actually much larger, but since we only access
    #the first two data members via FFI and always deal with struct pointers
    #there is no need to mess around with the rest of the object.
    class PyObjectStruct < FFI::Struct
      layout :ob_refcnt, :int,
        :ob_type, :pointer
    end

  end
end
