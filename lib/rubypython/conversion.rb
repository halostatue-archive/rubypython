require 'rubypython/python'
require 'rubypython/macros'
module RubyPython
  #This modules encapsulates the work of converting between native Ruby and
  #Python types. Unsupported conversions raise {UnsupportedConversion}. 
  module Conversion

    #Raised when RubyPython does not know how to convert an object from Python
    #to Ruby or vice versa
    class UnsupportedConversion < Exception; end

    def self.rtopString(rString)
      Python.PyString_FromString(rString)
    end

    def self.rtopArrayToList(rArray)
      size = rArray.length
      pList = Python.PyList_New size
      rArray.each_with_index do |el, i|
        Python.PyList_SetItem pList, i, rtopObject(el)
      end
      pList
    end

    def self.rtopArrayToTuple(rArray)
      pList = rtopArrayToList(rArray)
      pTuple = Python.PySequence_Tuple(pList)
      Python.Py_DecRef(pList)
      pTuple
    end

    def self.rtopHash(rHash)
      pDict = Python.PyDict_New
      rHash.each do |k,v|
        Python.PyDict_SetItem pDict, rtopObject(k, key=true), rtopObject(v)
      end
      pDict
    end

    def self.rtopFixnum(rNum)
      Python.PyInt_FromLong(rNum)
    end

    def self.rtopBigNum(rNum)
      Python.PyLong_FromLong(rNum)
    end

    def self.rtopFloat(rNum)
      Python.PyFloat_FromDouble(rNum)
    end

    def self.rtopFalse
      Macros.Py_RETURN_FALSE
    end

    def self.rtopTrue
      Macros.Py_RETURN_TRUE
    end

    def self.rtopNone
      Macros.Py_RETURN_NONE
    end

    def self.rtopSymbol(rSymbol)
      Python.PyString_FromString rSymbol.to_s
    end

    #If possible converts a ruby type to an equivalent
    #python native type.
    #@param rObj a native ruby type
    #@param [Boolean] is_key whether this object will be used as a key in a
    #  python dict.
    #@return [FFI::Pointer] a to a C PyObject\*
    #@raise [UnsupportedConversion]
    def self.rtopObject(rObj, is_key=false)
      case rObj
      when String
        rtopString rObj
      when Array
        # If this object is going to be used as a
        # hash key we should make it a tuple instead
        # of a list
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
      when nil
        rtopNone
      else
        raise UnsupportedConversion.new("Unsupported type for RTOP conversion." )
      end
    end

    def self.ptorString(pString)
      Python.PyString_AsString(pString)
    end

    def self.ptorList(pList)
      rb_array = []
      list_size = Python.PyList_Size(pList)

      list_size.times do |i|
        element = Python.PyList_GetItem(pList, i)
        Python.Py_IncRef element
        rObject = ptorObject(element)
        rb_array.push rObject
      end

      rb_array
    end

    def self.ptorInt(pNum)
      Python.PyInt_AsLong pNum
    end

    def self.ptorLong(pNum)
      Python.PyLong_AsLong(pNum)
      #TODO Overflow Checking
    end

    def self.ptorFloat(pNum)
      Python.PyFloat_AsDouble(pNum)
    end

    def self.ptorTuple(pTuple)
      pList = Python.PySequence_List pTuple
      rArray = ptorList pList
      Python.Py_DecRef pList
      rArray
    end

    def self.ptorDict(pDict)
      rb_hash = {}

      pos = FFI::MemoryPointer.new :ssize_t
      pos.write_int 0
      key = FFI::MemoryPointer.new :pointer
      val = FFI::MemoryPointer.new :pointer

      while Python.PyDict_Next(pDict, pos, key, val) != 0
        pKey = key.read_pointer
        pVal = val.read_pointer
        rKey = ptorObject(pKey)
        rVal = ptorObject(pVal)
        rb_hash[rKey] = rVal
      end

      rb_hash
    end


    #Converts a pointer to a Python object into a native ruby type, if
    #possible. Otherwise raises an error.
    #@param [FFI::Pointer] pObj a pointer to a Python object
    #@return a native ruby object.
    #@raise {UnsupportedConversion}
    def self.ptorObject(pObj)
      if Macros.PyObject_TypeCheck(pObj, Python.PyString_Type.to_ptr) != 0
        ptorString pObj
      elsif Macros.PyObject_TypeCheck(pObj, Python.PyList_Type.to_ptr) != 0
        ptorList pObj
      elsif Macros.PyObject_TypeCheck(pObj, Python.PyInt_Type.to_ptr) != 0
        ptorInt pObj
      elsif Macros.PyObject_TypeCheck(pObj, Python.PyLong_Type.to_ptr) != 0
        ptorLong pObj
      elsif Macros.PyObject_TypeCheck(pObj, Python.PyFloat_Type.to_ptr) != 0
        ptorFloat pObj
      elsif Macros.PyObject_TypeCheck(pObj, Python.PyTuple_Type.to_ptr) != 0
        ptorTuple pObj
      elsif Macros.PyObject_TypeCheck(pObj, Python.PyDict_Type.to_ptr) != 0
        ptorDict pObj
      elsif pObj == Macros.Py_True
        true
      elsif pObj == Macros.Py_False
        false
      elsif pObj == Macros.Py_None
        nil
      else
        pObj
      end
    end
  end
end
