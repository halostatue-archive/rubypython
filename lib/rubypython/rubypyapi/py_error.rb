require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'


module RubyPyApi
  class PythonError < Exception

    def self.fetch(rbType, rbValue, rbTraceback)
      rbType.xDecref
      rbValue.xDecref
      rbTraceback.xDecref

      typePointer = FFI::MemoryPointer.new :pointer
      valuePointer = FFI::MemoryPointer.new :pointer
      tracebackPointer = FFI::MemoryPointer.new :pointer

      Python.PyErr_fetch typePointer, valuePointer, tracebackPointer
      true
    end

    def self.error?
      Python.PyErr_Occurred.address != 0
    end

    def self.clear
      Python.PyErr_Clear
    end

  end
end
