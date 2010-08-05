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

    #This class wraps C PyObject*s so that the their Python reference count is
    #automatically decreased when the Ruby object referencing them 
    #goes out of scope.
    class AutoPyPointer < FFI::AutoPointer
      def self.release(pointer)
        Python.Py_DecRef pointer if Python.IsInitialized == 1 
      end
    end

    attr_reader :pointer

    #@param [FFI::Pointer, other] pointer objects passed in to the constructor
    #   are just assigned to the pointer attribute of the instance. All other
    #   objects are converted via {RTOP#rtopObject} before being assigned.
    def initialize(rObject)
      if rObject.kind_of? FFI::Pointer 
        @pointer = AutoPyPointer.new rObject
        xIncref if rObject.is_a? AutoPyPointer
      else
        @pointer = AutoPyPointer.new RTOP.rtopObject(rObject)
      end
    end

    #Attempts to convert the wrapped object to a native ruby type.
    #@return a ruby version of the wrapped object
    #@raise [{PTOR::UnsupportedConversion}]
    def rubify
      PTOR.ptorObject @pointer
    end

    #Tests whether the wrapped object has a given attribute
    #@param [String] the name of the attribute to look up
    #@return [Boolean]
    def hasAttr(attrName)
      Python.PyObject_HasAttrString(@pointer, attrName) == 1
    end

    #Retrieves an object from the wrapped python object
    #@param [String] the name of attribute to fetch
    #@return [{PyObject}] a Ruby wrapper around the fetched attribute
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

    def class?
      isClassObj = (Macros.PyObject_TypeCheck(@pointer, Python.PyClass_Type.to_ptr) == 1)
      isTypeObj = (Macros.PyObject_TypeCheck(@pointer, Python.PyType_Type.to_ptr) == 1)
      isTypeObj or isClassObj
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
          arg.pObject
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
