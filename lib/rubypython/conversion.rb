require 'rubypython/python'
require 'rubypython/macros'

# Acts as a namespace for methods to bidirectionally convert between native
# Ruby types and native \Python types. Unsupported conversions raise
# UnsupportedConversion.
#
# The methods in this module should be considered internal implementation to
# RubyPython as they all return FFI pointers to \Python objects.
module RubyPython::Conversion
  # Raised when RubyPython does not know how to convert an object from
  # \Python to Ruby or vice versa.
  class UnsupportedConversion < Exception; end

  # Convert a Ruby string to a \Python string. Returns an FFI::Pointer to
  # a PyStringObject.
  def self.rtopString(rString)
    size = rString.respond_to?(:bytesize) ? rString.bytesize : rString.size
    RubyPython::Python.PyString_FromStringAndSize(rString, size)
  end

  # Convert a Ruby Array to \Python List. Returns an FFI::Pointer to
  # a PyListObject.
  def self.rtopArrayToList(rArray)
    size = rArray.length
    pList = RubyPython::Python.PyList_New size
    rArray.each_with_index do |el, i|
      RubyPython::Python.PyList_SetItem pList, i, rtopObject(el)
    end
    pList
  end

  # Convert a Ruby Array (including the subclass RubyPython::Tuple) to
  # \Python \tuple. Returns an FFI::Pointer to a PyTupleObject.
  def self.rtopArrayToTuple(rArray)
    pList = rtopArrayToList(rArray)
    pTuple = RubyPython::Python.PySequence_Tuple(pList)
    RubyPython::Python.Py_DecRef(pList)
    pTuple
  end

  # Convert a Ruby Hash to a \Python Dict. Returns an FFI::Pointer to a
  # PyDictObject.
  def self.rtopHash(rHash)
    pDict = RubyPython::Python.PyDict_New
    rHash.each do |k,v|
      RubyPython::Python.PyDict_SetItem pDict, rtopObject(k, key = true),
        rtopObject(v)
    end
    pDict
  end

  # Convert a Ruby Fixnum to a \Python Int. Returns an FFI::Pointer to a
  # PyIntObject.
  def self.rtopFixnum(rNum)
    RubyPython::Python.PyInt_FromLong(rNum)
  end

  # Convert a Ruby Bignum to a \Python Long. Returns an FFI::Pointer to a
  # PyLongObject.
  def self.rtopBigNum(rNum)
    RubyPython::Python.PyLong_FromLong(rNum)
  end

  # Convert a Ruby float to a \Python Float. Returns an FFI::Pointer to a
  # PyFloatObject.
  def self.rtopFloat(rNum)
    RubyPython::Python.PyFloat_FromDouble(rNum)
  end

  # Returns a \Python False value (equivalent to Ruby's +false+). Returns an
  # FFI::Pointer to Py_ZeroStruct.
  def self.rtopFalse
    RubyPython::Macros.Py_RETURN_FALSE
  end

  # Returns a \Python True value (equivalent to Ruby's +true+). Returns an
  # FFI::Pointer to Py_TrueStruct.
  def self.rtopTrue
    RubyPython::Macros.Py_RETURN_TRUE
  end

  # Returns a \Python None value (equivalent to Ruby's +nil+). Returns an
  # FFI::Pointer to Py_NoneStruct.
  def self.rtopNone
    RubyPython::Macros.Py_RETURN_NONE
  end

  # Convert a Ruby Symbol to a \Python String. Returns an FFI::Pointer to a
  # PyStringObject.
  def self.rtopSymbol(rSymbol)
    RubyPython::Python.PyString_FromString rSymbol.to_s
  end

  # Convert a Ruby Proc to a \Python Function. Returns an FFI::Pointer to a
  # PyCFunction.
  def self.rtopFunction(rObj)
    proc = ::FFI::Function.new(:pointer, [:pointer, :pointer]) do |p_self, p_args|
      retval = rObj.call(*ptorTuple(p_args))
      pObject = retval.is_a?(RubyPython::RubyPyProxy) ? retval.pObject : RubyPython::PyObject.new(retval)

      # make sure the refcount is >1 when pObject is destroyed
      pObject.xIncref
      pObject.pointer
    end

    defn = RubyPython::Python::PyMethodDef.new
    defn[:ml_name] = ::FFI::MemoryPointer.from_string("RubyPython::Proc::%s" % rObj.object_id)
    defn[:ml_meth] = proc
    defn[:ml_flags] = RubyPython::Python::METH_VARARGS
    defn[:ml_doc] = nil

    return RubyPython::Python.PyCFunction_New(defn, nil)
  end

  # This will attempt to convert a Ruby object to an equivalent \Python
  # native type. Returns an FFI::Pointer to a \Python object (the
  # appropriate Py…Object C structure). If the conversion is unsuccessful,
  # will raise UnsupportedConversion.
  #
  # [rObj]    A native Ruby object.
  # [is_key]  Set to +true+ if the provided Ruby object will be used as a
  #           key in a \Python +dict+. (This primarily matters for Array
  #           conversion.)
  def self.rtopObject(rObj, is_key = false)
    case rObj
    when String
      rtopString rObj
    when RubyPython::Tuple
      rtopArrayToTuple rObj
    when Array
      # If this object is going to be used as a hash key we should make it a
      # tuple instead of a list
      if is_key
        rtopArrayToTuple rObj
      else
        rtopArrayToList rObj
      end
    when Hash
      rtopHash rObj
    when Fixnum
      rtopFixnum rObj
    when Bignum
      rtopBignum rObj
    when Float
      rtopFloat rObj
    when true
      rtopTrue
    when false
      rtopFalse
    when Symbol
      rtopSymbol rObj
    when Proc, Method
      rtopFunction rObj
    when nil
      rtopNone
    when RubyPython::PyObject
      rObj.pointer
    else
      raise UnsupportedConversion.new("Unsupported type #{rObj.class} for conversion.")
    end
  end

  # Convert an FFI::Pointer to a \Python String (PyStringObject) to a Ruby
  # String.
  def self.ptorString(pString)
    strPtr  = ::FFI::MemoryPointer.new(:pointer)
    sizePtr = ::FFI::MemoryPointer.new(:ssize_t)

    RubyPython::Python.PyString_AsStringAndSize(pString, strPtr, sizePtr)

    size = case ::FFI.find_type(:ssize_t)
           when ::FFI.find_type(:long)
             sizePtr.read_long
           when ::FFI.find_type(:int)
             sizePtr.read_int
           when ::FFI.find_type(:long_long)
             sizePtr.read_long_long
           else
             nil
           end

    strPtr.read_pointer.read_string(size)
  end

  # Convert an FFI::Pointer to a \Python List (PyListObject) to a Ruby
  # Array.
  def self.ptorList(pList)
    rb_array = []
    list_size = RubyPython::Python.PyList_Size(pList)

    list_size.times do |i|
      element = RubyPython::Python.PyList_GetItem(pList, i)
      # PyList_GetItem returns borrowed ref
      RubyPython::Python.Py_IncRef element
      rObject = ptorObject(element)
      rb_array.push rObject
    end

    rb_array
  end

  # Convert an FFI::Pointer to a \Python Int (PyIntObject) to a Ruby Fixnum.
  def self.ptorInt(pNum)
    RubyPython::Python.PyInt_AsLong(pNum)
  end

  # Convert an FFI::Pointer to a \Python Long (PyLongObject) to a Ruby
  # Fixnum. This version does not do overflow checking, but probably should.
  def self.ptorLong(pNum)
    RubyPython::Python.PyLong_AsLong(pNum)
    # TODO Overflow Checking
  end

  # Convert an FFI::Pointer to a \Python Float (PyFloatObject) to a Ruby
  # Float.
  def self.ptorFloat(pNum)
    RubyPython::Python.PyFloat_AsDouble(pNum)
  end

  # Convert an FFI::Pointer to a \Python Tuple (PyTupleObject) to an
  # instance of RubyPython::Tuple, a subclass of the Ruby Array class.
  def self.ptorTuple(pTuple)
    pList = RubyPython::Python.PySequence_List pTuple
    rArray = ptorList pList
    RubyPython::Python.Py_DecRef pList
    RubyPython::Tuple.tuple(rArray)
  end

  # Convert an FFI::Pointer to a \Python Dictionary (PyDictObject) to a Ruby
  # Hash.
  def self.ptorDict(pDict)
    rb_hash = {}

    pos = ::FFI::MemoryPointer.new :ssize_t
    pos.write_int 0
    key = ::FFI::MemoryPointer.new :pointer
    val = ::FFI::MemoryPointer.new :pointer

    while RubyPython::Python.PyDict_Next(pDict, pos, key, val) != 0
      pKey = key.read_pointer
      pVal = val.read_pointer
      rKey = ptorObject(pKey)
      rVal = ptorObject(pVal)
      rb_hash[rKey] = rVal
    end

    rb_hash
  end

  # Converts a pointer to a \Python object into a native Ruby type, if
  # possible. If the conversion cannot be done, the Python object will be
  # returned unmodified.
  #
  # [pObj]  An FFI::Pointer to a \Python object.
  def self.ptorObject(pObj)
    if RubyPython::Macros.PyObject_TypeCheck(pObj, RubyPython::Python.PyString_Type.to_ptr) != 0
      ptorString pObj
    elsif RubyPython::Macros.PyObject_TypeCheck(pObj, RubyPython::Python.PyList_Type.to_ptr) != 0
      ptorList pObj
    elsif RubyPython::Macros.PyObject_TypeCheck(pObj, RubyPython::Python.PyInt_Type.to_ptr) != 0
      ptorInt pObj
    elsif RubyPython::Macros.PyObject_TypeCheck(pObj, RubyPython::Python.PyLong_Type.to_ptr) != 0
      ptorLong pObj
    elsif RubyPython::Macros.PyObject_TypeCheck(pObj, RubyPython::Python.PyFloat_Type.to_ptr) != 0
      ptorFloat pObj
    elsif RubyPython::Macros.PyObject_TypeCheck(pObj, RubyPython::Python.PyTuple_Type.to_ptr) != 0
      ptorTuple pObj
    elsif RubyPython::Macros.PyObject_TypeCheck(pObj, RubyPython::Python.PyDict_Type.to_ptr) != 0
      ptorDict pObj
    elsif pObj == RubyPython::Macros.Py_True
      true
    elsif pObj == RubyPython::Macros.Py_False
      false
    elsif pObj == RubyPython::Macros.Py_None
      nil
    else
      pObj
    end
  end
end
