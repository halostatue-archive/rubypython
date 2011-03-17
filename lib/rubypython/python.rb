require 'ffi'
require 'rubypython/options'
require 'rubypython/pythonexec'

module RubyPython
  unless defined? PYTHON_RB
    PYTHON_RB = __FILE__
    PYTHON_RB.freeze
  end

  module Python; end
end

if RubyPython.load_ffi?
  # This module provides access to the \Python C API functions via the Ruby
  # FFI gem.
  #
  # === Documentation
  # * {Python C API}[http://docs.python.org/c-api/]
  # * {Ruby FFI}[http://rdoc.info/projects/ffi/ffi]
  module RubyPython::Python # :nodoc: all
    extend FFI::Library

    EXEC = RubyPython::PythonExec.new(RubyPython.options[:python_exe])

    PYTHON_LIB = EXEC.library
    # FFI::DynamicLibrary::RTLD_LAZY | FFI::DynamicLibrary::RTLD_GLOBAL
    ffi_lib_flags :lazy, :global
    ffi_lib EXEC.library

    # The class is a little bit of a hack to extract the address of global
    # structs. If someone knows a better way please let me know.
    class DummyStruct < FFI::Struct # :nodoc:
      layout :dummy_var, :int
    end

    PY_FILE_INPUT = 257
    PY_EVAL_INPUT = 258

    # Function methods & constants
    METH_VARARGS = 0x0001
    attach_function :PyCFunction_New, [:pointer, :pointer], :pointer
    callback :PyCFunction, [:pointer, :pointer], :pointer

    attach_function :PyRun_String, [:string, :int, :pointer, :pointer], :pointer
    attach_function :PyRun_SimpleString, [:string], :pointer
    attach_function :Py_CompileString, [:string, :string, :int], :pointer
    attach_function :PyEval_EvalCode, [:pointer, :pointer, :pointer], :pointer
    attach_function :PyErr_SetString, [:pointer, :string], :void

    # Python interpreter startup and shutdown
    attach_function :Py_IsInitialized, [], :int
    attach_function :Py_Initialize, [], :void
    attach_function :Py_Finalize, [], :void

    # Module methods
    attach_function :PyImport_ImportModule, [:string], :pointer

    # Object Methods
    attach_function :PyObject_HasAttrString, [:pointer, :string], :int
    attach_function :PyObject_GetAttrString, [:pointer, :string], :pointer
    attach_function :PyObject_SetAttrString, [:pointer, :string, :pointer], :int
    attach_function :PyObject_Dir, [:pointer], :pointer

    attach_function :PyObject_Compare, [:pointer, :pointer], :int

    attach_function :PyObject_Call, [:pointer, :pointer, :pointer], :pointer
    attach_function :PyObject_CallObject, [:pointer, :pointer], :pointer
    attach_function :PyCallable_Check, [:pointer], :int

    ### Python To Ruby Conversion
    # String Methods
    attach_function :PyString_AsString, [:pointer], :string
    attach_function :PyString_FromString, [:string], :pointer
    attach_function :PyString_AsStringAndSize, [:pointer, :pointer, :pointer], :int
    attach_function :PyString_FromStringAndSize, [:buffer_in, :ssize_t], :pointer

    # List Methods
    attach_function :PyList_GetItem, [:pointer, :int], :pointer
    attach_function :PyList_Size, [:pointer], :int
    attach_function :PyList_New, [:int], :pointer
    attach_function :PyList_SetItem, [:pointer, :int, :pointer], :void

    # Integer Methods
    attach_function :PyInt_AsLong, [:pointer], :long
    attach_function :PyInt_FromLong, [:long], :pointer

    attach_function :PyLong_AsLong, [:pointer], :long
    attach_function :PyLong_FromLong, [:pointer], :long

    # Float Methods
    attach_function :PyFloat_AsDouble, [:pointer], :double
    attach_function :PyFloat_FromDouble, [:double], :pointer

    # Tuple Methods
    attach_function :PySequence_List, [:pointer], :pointer
    attach_function :PySequence_Tuple, [:pointer], :pointer
    attach_function :PyTuple_Pack, [:int, :varargs], :pointer

    # Dict/Hash Methods
    attach_function :PyDict_Next, [:pointer, :pointer, :pointer, :pointer], :int
    attach_function :PyDict_New, [], :pointer
    attach_function :PyDict_SetItem, [:pointer, :pointer, :pointer], :int
    attach_function :PyDict_Contains, [:pointer, :pointer], :int
    attach_function :PyDict_GetItem, [:pointer, :pointer], :pointer

    # Error Methods
    attach_variable :PyExc_Exception, DummyStruct.by_ref
    attach_variable :PyExc_StopIteration, DummyStruct.by_ref
    attach_function :PyErr_SetNone, [:pointer], :void
    attach_function :PyErr_Fetch, [:pointer, :pointer, :pointer], :void
    attach_function :PyErr_Occurred, [], :pointer
    attach_function :PyErr_Clear, [], :void

    # Reference Counting
    attach_function :Py_IncRef, [:pointer], :void
    attach_function :Py_DecRef, [:pointer], :void

    # Type Objects
    # attach_variable :PyBaseObject_Type, DummyStruct.by_value # built-in 'object' 
    # attach_variable :PyBaseString_Type, DummyStruct.by_value
    # attach_variable :PyBool_Type, DummyStruct.by_value
    # attach_variable :PyBuffer_Type, DummyStruct.by_value
    # attach_variable :PyByteArrayIter_Type, DummyStruct.by_value
    # attach_variable :PyByteArray_Type, DummyStruct.by_value
    attach_variable :PyCFunction_Type, DummyStruct.by_value
    # attach_variable :PyCObject_Type, DummyStruct.by_value
    # attach_variable :PyCallIter_Type, DummyStruct.by_value
    # attach_variable :PyCapsule_Type, DummyStruct.by_value
    # attach_variable :PyCell_Type, DummyStruct.by_value
    # attach_variable :PyClassMethod_Type, DummyStruct.by_value
    attach_variable :PyClass_Type, DummyStruct.by_value
    # attach_variable :PyCode_Type, DummyStruct.by_value
    # attach_variable :PyComplex_Type, DummyStruct.by_value
    # attach_variable :PyDictItems_Type, DummyStruct.by_value
    # attach_variable :PyDictIterItem_Type, DummyStruct.by_value
    # attach_variable :PyDictIterKey_Type, DummyStruct.by_value
    # attach_variable :PyDictIterValue_Type, DummyStruct.by_value
    # attach_variable :PyDictKeys_Type, DummyStruct.by_value
    # attach_variable :PyDictProxy_Type, DummyStruct.by_value
    # attach_variable :PyDictValues_Type, DummyStruct.by_value
    attach_variable :PyDict_Type, DummyStruct.by_value
    # attach_variable :PyEllipsis_Type, DummyStruct.by_value
    # attach_variable :PyEnum_Type, DummyStruct.by_value
    # attach_variable :PyFile_Type, DummyStruct.by_value
    attach_variable :PyFloat_Type, DummyStruct.by_value
    # attach_variable :PyFrame_Type, DummyStruct.by_value
    # attach_variable :PyFrozenSet_Type, DummyStruct.by_value
    attach_variable :PyFunction_Type, DummyStruct.by_value
    # attach_variable :PyGen_Type, DummyStruct.by_value
    # attach_variable :PyGetSetDescr_Type, DummyStruct.by_value
    # attach_variable :PyInstance_Type, DummyStruct.by_value
    attach_variable :PyInt_Type, DummyStruct.by_value
    attach_variable :PyList_Type, DummyStruct.by_value
    attach_variable :PyLong_Type, DummyStruct.by_value
    # attach_variable :PyMemberDescr_Type, DummyStruct.by_value
    # attach_variable :PyMemoryView_Type, DummyStruct.by_value
    attach_variable :PyMethod_Type, DummyStruct.by_value
    # attach_variable :PyModule_Type, DummyStruct.by_value
    # attach_variable :PyNullImporter_Type, DummyStruct.by_value
    # attach_variable :PyProperty_Type, DummyStruct.by_value
    # attach_variable :PyRange_Type, DummyStruct.by_value
    # attach_variable :PyReversed_Type, DummyStruct.by_value
    # attach_variable :PySTEntry_Type, DummyStruct.by_value
    # attach_variable :PySeqIter_Type, DummyStruct.by_value
    # attach_variable :PySet_Type, DummyStruct.by_value
    # attach_variable :PySlice_Type, DummyStruct.by_value
    # attach_variable :PyStaticMethod_Type, DummyStruct.by_value
    attach_variable :PyString_Type, DummyStruct.by_value
    # attach_variable :PySuper_Type, DummyStruct.by_value # built-in 'super' 
    # attach_variable :PyTraceBack_Type, DummyStruct.by_value
    attach_variable :PyTuple_Type, DummyStruct.by_value
    attach_variable :PyType_Type, DummyStruct.by_value
    # attach_variable :PyUnicode_Type, DummyStruct.by_value
    # attach_variable :PyWrapperDescr_Type, DummyStruct.by_value

    attach_variable :Py_TrueStruct, :_Py_TrueStruct, DummyStruct.by_value
    attach_variable :Py_ZeroStruct, :_Py_ZeroStruct, DummyStruct.by_value
    attach_variable :Py_NoneStruct, :_Py_NoneStruct, DummyStruct.by_value

    # This is an implementation of the basic structure of a Python PyObject
    # struct. The C struct is actually much larger, but since we only access
    # the first two data members via FFI and always deal with struct
    # pointers there is no need to mess around with the rest of the object.
    class PyObjectStruct < FFI::Struct
      layout :ob_refcnt, :ssize_t,
             :ob_type, :pointer
    end

    # This struct is used when defining Python methods.
    class PyMethodDef < FFI::Struct
      layout :ml_name, :pointer,
             :ml_meth, :PyCFunction,
             :ml_flags, :int,
             :ml_doc, :pointer
    end
  end
end
