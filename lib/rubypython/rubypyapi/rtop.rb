require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'

module RubyPython
  module RubyPyApi
    #This modules encapsulates the work of converting ruby objects
    #to native Python types, so that they may be passed to the python
    #interpreter.
    module RTOP
      def self.rtopString(rString)
        Python.PyString_FromString(rString)
      end

      def self.rtopArrayToList(rArray)
        size = rArray.length
        pList = Python.PyList_New size
        rArray.each_with_index do |el, i|
          Python.PyList_SetItem pList, i, rtopObject(el)
        end
        pList
      end

      def self.rtopArrayToTuple(rArray)
        pList = rtopArrayToList(rArray)
        pTuple = Python.PySequence_Tuple(pList)
        Python.Py_DecRef(pList)
        pTuple
      end

      def self.rtopHash(rHash)
        pDict = Python.PyDict_New
        rHash.each do |k,v|
          Python.PyDict_SetItem pDict, rtopObject(k, key=true), rtopObject(v)
        end
        pDict
      end

      def self.rtopFixnum(rNum)
        Python.PyInt_FromLong(rNum)
      end

      def self.rtopBigNum(rNum)
        Python.PyLong_FromLong(rNum)
      end

      def self.rtopFloat(rNum)
        Python.PyFloat_FromDouble(rNum)
      end

      def self.rtopFalse
        Macros.Py_RETURN_FALSE
      end

      def self.rtopTrue
        Macros.Py_RETURN_TRUE
      end

      def self.rtopNone
        Macros.Py_RETURN_NONE
      end

      def self.rtopSymbol(rSymbol)
        Python.PyString_FromString rSymbol.to_s
      end

      #If possible converts a ruby type to an equivalent
      #python native type.
      #@param rObj a native ruby type
      #@param [Boolean] is_key whether this object will be used as a key in a
      #  python dict.
      #@return an FFI::Pointer wrapping a C PyObject*
      def self.rtopObject(rObj, is_key=false)
        case rObj
        when String
          rtopString rObj
        when Array
          # If this object is going to be used as a
          # hash key we should make it a tuple instead
          # of a list
          if is_key
            rtopArrayToTuple rObj
          else
            rtopArrayToList rObj
          end
        when Hash
          rtopHash rObj
        when Fixnum
          rtopFixnum rObj
        when Bignum
          rtopBignum rObj
        when Float
          rtopFloat rObj
        when true
          rtopTrue
        when false
          rtopFalse
        when Symbol
          rtopSymbol rObj
        else
          rtopNone
        end
      end

    end
  end
end
