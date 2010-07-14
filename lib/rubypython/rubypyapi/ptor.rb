require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'

module RubyPyApi
  module PTOR

    def ptorString(pString)
      Python.PyString_AsString(pString)
    end

    def ptorList(pList)
      rb_array = []
      list_size = Python.PyList_Size(pList)
      
      list_size.times do |i|
	element = Python.PyList_GetItem(pList, i)
	Macros.rpPy_mXINCREF element
	rObject = ptorObject(element)
	rb_array.push rObject
      end

      rb_array
    end

    def ptorInt(pNum)
      Python.PyInt_AsLong pNum
    end

    def ptorLong(pNum)
      Python.PyLong_AsLong(pNum)
      #TODO Overflow Checking
    end

    def ptorFloat(pNum)
      Python.PyFloat_AsDouble(pNum)
    end

    def ptorTuple(pTuple)
      pList = Python.PySequence_List pTuple
      rArray = ptorList pList
      Macros.rpPy_mXDECREF pList
      rArray
    end

    def ptorDict(pDict)
      rb_hash = {}

      pos = FFI::MemoryPointer.new :int
      key = FFI::MemoryPointer.new :pointer
      val = FFI::MemoryPointer.new :pointer

      while Python.PyDict_Next(pDict, pos, key, val)
	pKey = key.read_pointer
	pVal = val.read_pointer
	rKey = ptorObject(pKey)
	rVal = ptorObject(pVal)
	rb_hash[rKey] = rVal
      end

      return rb_hash
    end

      
    def ptorObject(pObj)
      rObj = nil

      if Macros.rpPyObject_mTypeCheck(pObj, Python.PyString_Type.to_ptr)
	ptorString pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyList_Type.to_ptr)
	ptorList pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyInt_Type.to_ptr)
	ptorInt pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyLong_Type.to_ptr)
	ptorLong pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyFloat_Type.to_ptr)
	ptorFloat pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyTuple_Type.to_ptr)
	ptorTuple pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyDict_Type.to_ptr)
	ptorDict pObj
      elsif pObj == Macros.rpPy_mTrue
	true
      elsif pObj == Macros.rpPy_mFalse
	false
      elsif pObj == Macros.rpPy_mNone
	nil
      end
    end

  end
end
