require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'


class PythonError < Exception

  def self.fetch(rbType, rbValue, rbTraceback)
    rbType.xDecref
    rbValue.xDecref
    rbTraceback.xDecref

    typePointer = FFI::MemoryPointer.new :pointer
    valuePointer = FFI::MemoryPointer.new :pointer
    tracebackPointer = FFI::MemoryPointer.new :pointer

    RubyPyApi::Python.PyErr_Fetch typePointer, valuePointer, tracebackPointer

    rbType.pObject = typePointer.read_pointer
    rbValue.pObject = valuePointer.read_pointer
    rbTraceback.pObject = tracebackPointer.read_pointer
    true
  end

  def self.error?
    RubyPyApi::Python.PyErr_Occurred.address != 0
  end

  def self.clear
    RubyPyApi::Python.PyErr_Clear
  end

end
