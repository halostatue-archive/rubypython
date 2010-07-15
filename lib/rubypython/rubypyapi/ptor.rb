require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'

module RubyPyApi
  module PTOR

    def self.ptorString(pString)
      Python.PyString_AsString(pString)
    end

    def self.ptorList(pList)
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
      Macros.rpPy_mXDECREF pList
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

      
    def self.ptorObject(pObj)
      if Macros.rpPyObject_mTypeCheck(pObj, Python.PyString_Type.to_ptr) != 0
	ptorString pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyList_Type.to_ptr) != 0
	ptorList pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyInt_Type.to_ptr) != 0
	ptorInt pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyLong_Type.to_ptr) != 0
	ptorLong pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyFloat_Type.to_ptr) != 0
	ptorFloat pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyTuple_Type.to_ptr) != 0
	ptorTuple pObj
      elsif Macros.rpPyObject_mTypeCheck(pObj, Python.PyDict_Type.to_ptr) != 0
	ptorDict pObj
      elsif pObj == Macros.rpPy_mTrue
	true
      elsif pObj == Macros.rpPy_mFalse
	false
      elsif pObj == Macros.rpPy_mNone
	nil
      else
        nil
      end
    end

  end
end
