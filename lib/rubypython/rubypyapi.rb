require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'
require 'rubypython/rubypyapi/ptor'
require 'rubypython/rubypyapi/rtop'
require 'rubypython/rubypyapi/py_object'

#This module is really only for internal use. The RubyPython module exports more
#user-friendly interfaces to the functionality provided within. It's internals
#are liable to change and odds are if you use this module directly your code
#will break with new releases.
module RubyPyApi

  @@legacy_mode = false

  def self.legacy_mode=(on_off)
    @@legacy_mode = on_off
  end

  def self.legacy_mode
    @@legacy_mode
  end

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

  def self.import(mname)
    pModule = Python.PyImport_ImportModule mname
    PyObject.new pModule
  end
end

