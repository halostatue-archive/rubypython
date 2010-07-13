#include "ptor.h"


/* Note:
   The conversion functions for the builtin types are just that,
   conversion functions. They create a new Ruby object equivalent to
   the given Python object, they do not wrap the Python object.

 */

VALUE ptorString(PyObject* pString)
{
  // Make sure pString is actually a string
	if(!PyString_Check(pString)) return Qnil;
	
	char* cStr;
	
	cStr = PyString_AsString(pString);
	
	return rb_str_new2(cStr);
}

VALUE ptorList(PyObject* pList)
{
  // Verify that pList is a python list
	if(!PyList_Check(pList)) return Qnil;

	VALUE rArray;
	VALUE rElement;
	PyObject* element;

	int i = 0;

	// Allocate a new Ruby array
	rArray = rb_ary_new();

	// Iteratively add converted elements to the new Ruby list
	int list_size = PyList_Size(pList);
	for(i = 0; i < list_size; i++)
	{
		element = PyList_GetItem(pList, i);
		Py_INCREF(element);
		rElement = ptorObject(element);
		rb_ary_push(rArray, rElement);
	}
	return rArray;
}

VALUE ptorInt(PyObject* pNum)
{
	if(!PyInt_Check(pNum)) return Qnil;
	
	VALUE rNum;
  
	rNum = INT2NUM(PyInt_AsLong(pNum));
	return rNum;
	
}

VALUE ptorLong(PyObject* pNum)
{
	if(!PyLong_Check(pNum)) return Qnil;

	VALUE rNum;
	long cNum;

	cNum = PyLong_AsLong(pNum);

	if(PyErr_ExceptionMatches(PyExc_OverflowError))
	{
		rpPythonError();
		return Qnil;
	}

	rNum = INT2NUM(cNum);

	return rNum;
	
}

VALUE ptorFloat(PyObject* pNum)
{
	if(!PyFloat_Check(pNum)) return Qnil;

	VALUE rNum;

	rNum = rb_float_new(PyFloat_AsDouble(pNum));

	return rNum;
}

VALUE ptorTuple(PyObject* pTuple)
{
	if(!PyTuple_Check(pTuple)) return Qnil;

	VALUE rArray;
	PyObject* pList;

	pList = PySequence_List(pTuple);
	rArray = ptorList(pList);
	Py_DECREF(pList);

	return rArray;
}


VALUE ptorDict(PyObject* pDict)
{
	if(!PyDict_Check(pDict)) return Qnil;

	VALUE rHash;
	VALUE rKey, rVal;
	PyObject *key,*val;
	Py_ssize_t pos = 0;

	rHash = rb_hash_new();

	while(PyDict_Next(pDict,&pos,&key,&val))
	{
		rKey = ptorObject(key);
		rVal = ptorObject(val);
		if(rKey == Qnil) continue;
		rb_hash_aset(rHash, rKey, rVal);
	}

	return rHash;
}

VALUE ptorObject(PyObject* pObj)
{
	VALUE rObj = (VALUE) NULL;

	// Test the Python object vs various types and convert / wrap it
	// appropriately.

	if(PyObject_TypeCheck(pObj,&PyString_Type))
	{
		rObj = ptorString(pObj);
	}
	if(PyObject_TypeCheck(pObj,&PyList_Type))
	{
		rObj = ptorList(pObj);
	}
	if(PyObject_TypeCheck(pObj,&PyInt_Type))
	{
		rObj = ptorInt(pObj);
	}
	if(PyObject_TypeCheck(pObj,&PyLong_Type))
	{
		rObj = ptorLong(pObj);
	}
	if(PyObject_TypeCheck(pObj,&PyFloat_Type))
	{
		rObj = ptorFloat(pObj);
	}
	if(PyObject_TypeCheck(pObj,&PyTuple_Type))
	{
		rObj = ptorTuple(pObj);
	}
	if(PyObject_TypeCheck(pObj,&PyDict_Type))
	{
		rObj = ptorDict(pObj);
	}
	if(pObj == Py_True)
	{
		rObj = Qtrue;
	}
	if(pObj == Py_False)
	{
		rObj = Qfalse;
	}
	if(pObj == Py_None)
	{
		rObj = Qnil;
	}
	if(!pObj)
		rObj = Qnil;

	// Fallthrough behavior: The object is a class which should be wrapped
	return rObj;
}

