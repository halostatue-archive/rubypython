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

    class AutoPyPointer < FFI::AutoPointer
      def self.release(pointer)
        Python.Py_DecRef pointer if Python.IsInitialized == 1 
      end
    end

    attr_reader :pointer

    def initialize(rObject)
      if rObject.kind_of? FFI::Pointer 
        @pointer = AutoPyPointer.new rObject
        xIncref if rObject.is_a? AutoPyPointer
      else
        @pointer = AutoPyPointer.new RTOP.rtopObject(rObject)
      end
    end

    def rubify
      PTOR.ptorObject @pointer
    end

    def hasAttr(attrName)
      Python.PyObject_HasAttrString(@pointer, attrName) == 1
    end

    def getAttr(attrName)
      pyAttr = Python.PyObject_GetAttrString @pointer, attrName
      self.class.new pyAttr
    end

    def setAttr(attrName, rbPyAttr)
      Python.PyObject_SetAttrString(@pointer, attrName, rbPyAttr.pointer) != -1
    end

    def callObject(rbPyArgs)
      pyReturn = Python.PyObject_CallObject(@pointer, rbPyArgs.pointer)
      self.class.new pyReturn
    end

    def xDecref
      @pointer = FFI::Pointer::NULL
    end

    def xIncref
      Python.Py_IncRef @pointer
    end

    def null?
      @pointer.null?
    end

    def cmp(other)
      Python.PyObject_Compare @pointer, other.pointer 
    end

    def functionOrMethod?
      isFunc = (Macros.PyObject_TypeCheck(@pointer, Python.PyFunction_Type.to_ptr) != 0)
      isMethod = (Macros.PyObject_TypeCheck(@pointer, Python.PyMethod_Type.to_ptr) != 0)
      isFunc or isMethod
    end

    def callable?
      Python.PyCallable_Check(@pointer) != 0
    end

    def self.makeTuple(rbObject)
      pTuple = nil

      if Macros.PyObject_TypeCheck(rbObject.pointer, Python.PyList_Type.to_ptr) != 0
        pTuple = Python.PySequence_Tuple(rbObject.pointer)
      elsif Macros.PyObject_TypeCheck(rbObject.pointer, Python.PyTuple_Type.to_ptr) != 0
        pTuple = rbObject.pointer
      else
        pTuple = Python.PyTuple_Pack(1, :pointer, rbObject.pointer)
      end

      self.new pTuple
    end

    def self.newList(*args)
      rbList = self.new Python.PyList_New(args.length)

      args.each_with_index do |el, i|
        Python.PyList_SetItem rbList.pointer, i, el.pointer
      end

      rbList
    end

    def self.convert(*args)
      args.map! do |arg|
        if arg.instance_of? RubyPyApi::PyObject
          arg
        elsif(arg.instance_of? RubyPyApi::RubyPyProxy)
          if(arg.pObject.null?)
            raise NullPObjectError.new("Null pointer.")
          else
            arg.pObject
          end
        else
          RubyPyApi::PyObject.new arg
        end
      end
    end

    def self.buildArgTuple(*args)
      pList = RubyPyApi::PyObject.newList(*args)
      pTuple = RubyPyApi::PyObject.makeTuple(pList)
      pList.xDecref
      pTuple
    end

  end

end
