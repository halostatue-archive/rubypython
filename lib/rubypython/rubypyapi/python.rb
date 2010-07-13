require 'ffi'
require 'open3'

module RubyPyApi::Python
  extend FFI::Library
  PYTHON_VERSION = Open3.popen3("python --version") { |i,o,e| e.read}.chomp.split[1].to_f
  PYTHON_NAME = "python#{PYTHON_VERSION}"
  LIB_NAME = "lib#{PYTHON_NAME}"
  LIB_EXT = "dylib"
  LIB = `python-config --prefix`.chomp +
   "/lib/#{PYTHON_NAME}/config/#{LIB_NAME}.#{LIB_EXT}"
  ffi_lib LIB

  attach_function :Py_IsInitialized, [], :int
  attach_function :Py_Initialize, [], :void
  attach_function :Py_Finalize, [], :void

end
