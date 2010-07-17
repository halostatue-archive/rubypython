require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'


class PythonError < Exception
  
  def initialize(typeName, msg)
    @type = typeName
    super([typeName, msg].join ': ')
  end

  def self.handle_error
    rbType, rbValue, rbTraceback = fetch()

    if not rbValue.null?
      msg = rbValue.getAttr("__str__").callObject RubyPyApi::PyObject.buildArgTuple
      msg = msg.rubify
    else
      msg = nil
    end
    
    #Decrease the reference count. This will happen anyway when they go
    #out of scope but might as well.
    rbValue.xDecref
    rbTraceback.xDecref
    pyName = rbType.getAttr("__name__")

    rbType.xDecref
    rbName = pyName.rubify
    pyName.xDecref

    PythonError.clear

    PythonError.new(rbName, msg)
  end

  def self.fetch
    typePointer = FFI::MemoryPointer.new :pointer
    valuePointer = FFI::MemoryPointer.new :pointer
    tracebackPointer = FFI::MemoryPointer.new :pointer

    RubyPyApi::Python.PyErr_Fetch typePointer, valuePointer, tracebackPointer

    rbType = RubyPyApi::PyObject.new typePointer.read_pointer
    rbValue = RubyPyApi::PyObject.new valuePointer.read_pointer
    rbTraceback = RubyPyApi::PyObject.new tracebackPointer.read_pointer
    [rbType, rbValue, rbTraceback]
  end

  def self.error?
    RubyPyApi::Python.PyErr_Occurred.address != 0
  end

  def self.clear
    RubyPyApi::Python.PyErr_Clear
  end

end
