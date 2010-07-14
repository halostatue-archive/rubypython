require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'
require 'rubypython/rubypyapi/ptor'
require 'rubypython/rubypyapi/rtop'
require 'ffi'

module RubyPyApi

  class FFIPyObject
    attr :pObject

    def initialize(rObject, has_pobject=true)
      if has_pobject
        @pObject = RTOP.rtopObject rObject
      end
    end

    def rubify
      PTOR.ptorObject @pObject
    end

    def hasAttr(attrName)
      Python.PyObject_HasAttrString(@pObject, attrName) == 1
    end

    def getAttr(attrName)
      pyAttr = Python.PyObject_GetAttrString @pObject, attrName
      rbAttr = self.class.new nil, false
      rbAttr.pObject = pyAttr
      rbAttr
    end

    def setAttr(attrName, rbPyAttr)
      Python.PyObject_SetAttrString(@pObject, attrName, rbPyAttr.pObject) != -1
    end

    def callObject(rbPyArgs)
      pyReturn = Python.PyObject_CallObject(@pObject, rbPyArgs.pObject)
      rbReturn = self.class.new nil, false
      rbReturn.pObject = pyReturn
      rbReturn
    end

    def xDecref
      Macros.rpPy_mXDECREF @pObject
    end

    def xIncref
      Macros.rpPy_mXINCREF @pObject
    end

    def null?
      @pObject == 0
    end

    def cmp(other)
      Python.PyObject_Compare @pObject, other.pObject 
    end

    def functionOrMethod?
      isFunc = (Macros.rbPyObject_mTypeCheck(@pObject, Python.PyFunction_Type.to_ptr) != 0)
      isMethod = (Macros.rbPyObject_mTypeCheck(@pObject, Python.PyMethod_Type.to_ptr) != 0)
      isFunc or isMethod
    end

    def callable?
      Macros.rbPyCallable_mCheck @pObject
    end

    def self.makeTuple(rbObject)
      pTuple = nil
      listType = FFI::MemoryPointer.new :pointer
      tupleType = FFI::MemoryPointer.new :pointer

      listType.write_pointer Python.PyList_Type
      tupleType.write_pointer Python.PyTuple_Type

      if Macros.rbPyObject_mTypeCheck(rbObject.pObject, listType) != 0
        pTuple = Python.PySequence_Tuple(rbObject.pObject)
      elsif Macros.rbPyObject_mTypeCheck(rbObject.pObject, tupleType) != 0
        ptuple = rbObject.pObject
      else
        pTuple = Python.PyTuple_Pack(1, rbObject.pObject)
      end

      rbTuple = self.new nil, false
      rbTuple.pObject = pTuple
      rbTuple
    end

    def self.newList(*args)
      rbList = self.new nil, false
      rbList.pObject = Python.PyList_New args.length

      args.each_with_index do |el, i|
        Python.PyList_SetItem rbList.pObject, i, el.pObject
      end

      rbList
    end

  end

end
