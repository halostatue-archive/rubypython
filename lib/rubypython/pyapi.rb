require 'rubypython/pyapi/python'
require 'rubypython/pyapi/macros'
require 'rubypython/pyapi/py_object'

module RubyPython
  #This module is really only for internal use. The RubyPython module exports more
  #user-friendly interfaces to the functionality provided within. It's internals
  #are liable to change and odds are if you use this module directly your code
  #will break with new releases.
  module PyAPI

    @@legacy_mode = false

    #@see RubyPython.legacy_mode=
    def self.legacy_mode=(on_off)
      @@legacy_mode = on_off
    end

    #@see RubyPython.legacy_mode
    def self.legacy_mode
      @@legacy_mode
    end

    #@see RubyPython.start
    def self.start
      if Python.Py_IsInitialized != 0
        return false
      end
      Python.Py_Initialize
      true
    end

    #@see RubyPython.stop
    def self.stop
      if Python.Py_IsInitialized !=0
        Python.Py_Finalize
        return true
      end
      false
    end

    #@see RubyPython.stop
    def self.import(mname)
      pModule = Python.PyImport_ImportModule mname
      PyObject.new pModule
    end
  end

end
