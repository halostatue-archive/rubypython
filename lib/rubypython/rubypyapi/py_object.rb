require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'
require 'rubypython/rubypyapi/ptor'
require 'rubypython/rubypyapi/rtop'
require 'ffi'

module RubyPyApi

  #This object is an opaque wrapper around the C PyObject* type used by the python
  #C API. This class <em>should not</em> be used by the end user. They should instead
  #make use of the RubyPyApi::RubyPyProxy class and its subclasses.
  class PyObject
    attr_accessor :pObject

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
      isFunc = (Macros.rpPyObject_mTypeCheck(@pObject, Python.PyFunction_Type.to_ptr) != 0)
      isMethod = (Macros.rpPyObject_mTypeCheck(@pObject, Python.PyMethod_Type.to_ptr) != 0)
      isFunc or isMethod
    end

    def callable?
      Macros.rpPyCallable_mCheck @pObject
    end

    def self.makeTuple(rbObject)
      pTuple = nil

      if Macros.rpPyObject_mTypeCheck(rbObject.pObject, Python.PyList_Type.to_ptr) != 0
        pTuple = Python.PySequence_Tuple(rbObject.pObject)
      elsif Macros.rpPyObject_mTypeCheck(rbObject.pObject, Python.PyTuple_Type.to_ptr) != 0
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

    def self.convert(*args)
      args.map! do |arg|
        if(arg.instance_of? RubyPyApi::PyObject)
          arg
        elsif(arg.instance_of?(RubyPyApi::RubyPyProxy))
          if(arg.pObject.null?)
            raise NullPObjectError.new("Null pObject pointer.")
          else
            arg.pObject
          end
        else
          RubyPyApi::PyObject.new(arg)
        end
      end
    end

    def self.buildArgTuple(*args)
      pList = RubyPyApi::PyObject.newList(*args)
      RubyPyApi::PyObject.makeTuple(pList)
    end
  end

end
