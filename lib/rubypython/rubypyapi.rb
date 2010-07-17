require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'
require 'rubypython/rubypyapi/ptor'
require 'rubypython/rubypyapi/rtop'
require 'rubypython/rubypyapi/py_object'

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

  #py_import
  def self.import(mname)
    pModule = Python.PyImport_ImportModule mname
    rModule = PyObject.new nil, false
    rModule.pointer = pModule
    rModule
  end

  #py_dict
  def self.dictContains(rbPyDict, rbPyKey)
    Python.PyDict_Contains(rbPyDict.pointer, rbPyKey.pointer) != 0
  end

  def self.dictGetItem(rbPyDict, rbPyKey)
    pyRetVal = Python.PyDict_GetItem(rbPyDict.pointer, rbPyKey.pointer)
    PyObject.new pyRetVal
  end

  def self.dictSetItem(rbPyDict, rbPyKey, rbPyItem)
    status = PyDict_SetItem rbPyDict.pointer, rbyPyKey.pointer, rbPyItem.pointer
    status != 0
  end

  #py_sys
  def self.sysGetObject(rbName)
    pReturn = Python.PySys_GetObject rbName
    rReturn = PyObject.new nil, false
    rReturn.pointer = pReturn
    rReturn
  end

  def self.sysSetObject(rbName, rbObject)
    Python.PySys_SetObject rbName, rbObject.pointer
  end

end

