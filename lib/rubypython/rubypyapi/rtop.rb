require 'rubypython/rubypyapi/python'
require 'rubypython/rubypyapi/macros'

module RubyPyApi
  module RTOP
    def rtopString(rString)
      Python.PyString_FromString(rString)
    end

    def rtopArrayToList(rArray)
      size = rArray.length
      pList = Python.PyList_New size
      rArray.each_w_index do |i, el|
        Python.PyList_SetItem pList, i, rtopObject(el)
      end
      pList
    end

    def rtopArrayToTuple(rArray)
      pList = rtopArrayToList(rArray)
      pTuple = Python.PySequence_Tuple(pList)
      Macros.rpPy_mXDECREF(pList)
      pTuple
    end

    def rtopHash(rHash)
      pDict = Python.PyDict_New
      rHash.each do |k,v|
        Python.PyDict_SetItem pDict, rtopObject(k, key=true), rtopObject(v)
      end
      pDict
    end

    def rtopFixnum(rNum)
      PyInt_FromLong(rNum)
    end

    def rtopBigNum(rNum)
      PyLong_FromLong(cNum)
    end

    def rtopFloat(rNum)
      PyFloat_FromDouble(rNum)
    end

    def rtopFalse
      Macros.rpPy_mRETURN_FALSE
    end

    def rtopTrue
      Macros.rpPy_mRETURN_TRUE
    end

    def rtopSymbol(rSymbol)
      Python.PyString_FromString rSymbol.to_s
    end

    def rtopObject(rObj, is_key=false)
      case rObj
      when String
        rtopString rObj
      when Array
        # If this object is going to be used as a
        # hash key we should make it a tuple instead
        # of a list
        if is_key pObj
          rtopArrayToTuple(rObj)
        else
          rtopArrayToList(robj)
        end
      when Hash
        rtopHash(rObj)
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
        pObj = Macros.rpPy_mNone
        Macros.rpPy_mXINCREF pObj
        pObj
      end
    end

  end
end
