require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'
require 'rubypython/rubypyapi/ptor'
require 'rubypython/rubypyapi/rtop'

module RubyPyApi

  def self.start
    if Python.Py_IsInitialized != 0
      return false
    end
    Python.Py_Initialize
    true
  end

  def self.stop
    if Python.Py_IsInitialized !=0
      Python.Py_Finalize
      return true
    end
    false
  end

end

