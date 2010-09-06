require 'rubypython/python'
require 'rubypython/macros'
require 'rubypython/conversion'
require 'ffi'

module RubyPython
  #This object is an opaque wrapper around the C PyObject\* type used by the
  #python C API. This class **should not** be used by the end user. They
  #should instead make use of the {RubyPyProxy} class and its
  #subclasses.
  class PyObject

    #@private
    #
    #This class wraps C PyObject\*s so that the Python reference count is
    #automatically decreased when the Ruby object referencing them 
    #goes out of scope.
    class AutoPyPointer < FFI::AutoPointer
      class << self
        #Keeps track of which objects are associated with the currently running
        #Python interpreter, so that RubyPython knows not to try to decrease the
        #reference counts of the others when garbage collecting.
        attr_accessor :current_pointers

        #When used along with the FFI Library method is executed whenever a
        #pointer is garbage collected so that cleanup can be done. In our case
        #we decrease the reference count of the held pointer as long as the
        #object is still good. There is really no reason the end-user would need
        #to the use this method directly.
        def release(pointer)
          obj_id = pointer.object_id
          if (Python.Py_IsInitialized != 0) and @current_pointers.delete(obj_id)
            Python.Py_DecRef pointer 
          end
        end
      end

      self.current_pointers = {}
    end

    #The FFI::Pointer object which represents the Python PyObject\*.
    attr_reader :pointer

    #@param [FFI::Pointer, other] pointer objects passed in to the constructor
    #   are just assigned to the pointer attribute of the instance. All other
    #   objects are converted via {Conversion.rtopObject} before being assigned.
    def initialize(rObject)
      if rObject.kind_of? FFI::AutoPointer 
        new_pointer = FFI::Pointer.new rObject
        @pointer = AutoPyPointer.new new_pointer
        xIncref
      elsif rObject.kind_of? FFI::Pointer
        @pointer = AutoPyPointer.new rObject
      else
        @pointer = AutoPyPointer.new Conversion.rtopObject(rObject)
      end
      AutoPyPointer.current_pointers[@pointer.object_id] = true
    end

    #Attempts to convert the wrapped object to a native ruby type.
    #@return a ruby version of the wrapped object
    def rubify
      Conversion.ptorObject @pointer
    end

    #Tests whether the wrapped object has a given attribute
    #@param [String] the name of the attribute to look up
    #@return [Boolean]
    def hasAttr(attrName)
      Python.PyObject_HasAttrString(@pointer, attrName) == 1
    end

    #Retrieves an object from the wrapped python object
    #@param [String] the name of attribute to fetch
    #@return [PyObject] a Ruby wrapper around the fetched attribute
    def getAttr(attrName)
      pyAttr = Python.PyObject_GetAttrString @pointer, attrName
      self.class.new pyAttr
    end

    #Sets the an attribute of the wrapped Python object
    #@param [String] attrName the name of of attribute to set
    #@param [PyObject] rbPyAttr a {PyObject} wrapper around the value we wish to
    #set the attribute to.
    #@return [Boolean] returns true if the attribute is sucessfully set.
    def setAttr(attrName, rbPyAttr)
      Python.PyObject_SetAttrString(@pointer, attrName, rbPyAttr.pointer) != -1
    end

    #Calls the wrapped Python object with the supplied arguments.
    #@param [PyObject] rbPyArgs a {PyObject} wrapping a tuple of the supplied
    #arguments
    #@return [PyObject] a {PyObject} wrapper around the returned
    #object (this may be NULL).
    def callObject(rbPyArgs)
      pyReturn = Python.PyObject_CallObject(@pointer, rbPyArgs.pointer)
      self.class.new pyReturn
    end

    #Decrease the reference count of the wrapped object
    #@return [void]
    def xDecref
      AutoPyPointer.release(@pointer)
      @pointer.free
    end

    #Increase the reference count of the wrapped object
    #@return [void]
    def xIncref
      Python.Py_IncRef @pointer
    end

    #Tests whether the wrapped object is NULL.
    def null?
      @pointer.null?
    end

    #@return [Number]
    def cmp(other)
      Python.PyObject_Compare @pointer, other.pointer 
    end

    #Tests whether the wrapped object is a function or a method. This is not the
    #same as {#callable?} as many other Python objects are callable.
    def function_or_method?
      isFunc = (Macros.PyObject_TypeCheck(@pointer, Python.PyFunction_Type.to_ptr) != 0)
      isMethod = (Macros.PyObject_TypeCheck(@pointer, Python.PyMethod_Type.to_ptr) != 0)
      isFunc or isMethod
    end

    #Is the wrapped object callable?
    def callable?
      Python.PyCallable_Check(@pointer) != 0
    end

    #Tests whether the wrapped object is a Python class (both new and old
    #style).
    def class?
      isClassObj = (Macros.PyObject_TypeCheck(@pointer, Python.PyClass_Type.to_ptr) == 1)
      isTypeObj = (Macros.PyObject_TypeCheck(@pointer, Python.PyType_Type.to_ptr) == 1)
      isTypeObj or isClassObj
    end

    #Manipulates the supplied {PyObject} instance such that it is suitable to
    #passed to {#callObject}. If `rbObject` is a tuple then the argument passed
    #in is returned. If it is a list then the list is converted to a tuple.
    #Otherwise returns a tuple with one element: `rbObject`.
    #@param [PyObject] rbObject the argment to be turned into a tuple.
    #@return [PyObject<tuple>]
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

    #Wraps up the supplied arguments in Python list.
    #@return [PyObject<list>]
    def self.newList(*args)
      rbList = self.new Python.PyList_New(args.length)

      args.each_with_index do |el, i|
        Python.PyList_SetItem rbList.pointer, i, el.pointer
      end

      rbList
    end

    #Converts the supplied arguments to PyObject instances.
    #@return [Array<PyObject>]
    def self.convert(*args)
      args.map! do |arg|
        if arg.kind_of? PyObject
          arg
        elsif arg.kind_of? RubyPyProxy
          arg.pObject
        else
          PyObject.new arg
        end
      end
    end

    #Takes an array of wrapped Python objects and wraps them in a tuple such
    #that they may be passed to {#callObject}.
    #@param [Array<PyObject>] args the arguments to be inserted into the tuple.
    #@return [PyObject<tuple>]
    def self.buildArgTuple(*args)
      pList = PyObject.newList(*args)
      pTuple = PyObject.makeTuple(pList)
      pList.xDecref
      pTuple
    end

  end

end
