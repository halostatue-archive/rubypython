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

  def import(mname)
    pModule = Python.PyImport_ImportModule mname
    rModule = PyObject.new nil, false
    rModule.pObject = pModule
    rModule
  end

  #py_dict
  def dictContains(rbPyDict, rbPyKey)
    Python.PyDict_Contains(rbPyDict.pObject, rbPyKey.pObject) != 0
  end

  def dictGetItem(rbPyDict, rbPyKey)
    pyRetVal = Python.PyDict_GetItem(rbPyDict.pObject, rbPyKey.pObject)
    FFIPyObject.new pyRetVal
  end

  def dictSetItem(rbPyDict, rbPyKey, rbPyItem)
    status = PyDict_SetItem rbPyDict.pObject, rbyPyKey.pObject, rbPyItem.pObject
    status != 0
  end

end

