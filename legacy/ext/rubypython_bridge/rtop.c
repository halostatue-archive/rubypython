#include "rtop.h"

RUBY_EXTERN VALUE cRbPyObj;
RUBY_EXTERN PyObject* rpObjectGetPyObject(VALUE self);

/*
*  Note: For the builtin types rubypython creates a copy of the ruby
*  object to pass into python. Builtin types are passed by VALUE not
*  by REFERENCE.
*/

PyObject* rtopString(VALUE rString)
{

	PyObject* pString;
	char* cString;

	cString = STR2CSTR(rString);

	pString = PyString_FromString(cString);

	return pString;
}


PyObject* rtopArrayToList(VALUE rArray)
{
	PyObject* pList;
	int i;
	int size = RARRAY_LEN(rArray);

	pList = PyList_New(size);

	for(i = 0; i < size; i++)
	{
		PyList_SetItem(pList, i, rtopObject(rb_ary_entry(rArray, i), 0));
	}

	return pList;
}

PyObject* rtopArrayToTuple(VALUE rArray)
{
	PyObject *pTuple,*pList;

	pList = rtopArrayToList(rArray);
	pTuple = PySequence_Tuple(pList);
	Py_XDECREF(pList);

	return pTuple;
}

PyObject* rtopHash(VALUE rHash)
{
	PyObject *pDict;
	VALUE rKeys;
	VALUE rKey, rVal;
	int i;
	
	pDict = PyDict_New();

	rKeys = rb_funcall(rHash, rb_intern("keys"), 0);
	
	for(i = 0; i < RARRAY_LEN(rKeys); i++)
	{
		rKey = rb_ary_entry(rKeys, i);
		rVal = rb_hash_aref(rHash, rKey);
		PyDict_SetItem(pDict, rtopObject(rKey, 1), rtopObject(rVal, 0));
	}

	return pDict;
}

PyObject* rtopFixnum(VALUE rNum)
{
	PyObject* pNum;
	long cNum;

	cNum = NUM2LONG(rNum);
	pNum = PyInt_FromLong(cNum);

	return pNum;
}

PyObject* rtopBignum(VALUE rNum)
{
	PyObject* pNum;
	long cNum;

	cNum = NUM2LONG(rNum);
	pNum = PyLong_FromLong(cNum);

	return pNum;
}

PyObject* rtopFloat(VALUE rNum)
{
	PyObject* pNum;
	double cNum;

	cNum = NUM2DBL(rNum);
	pNum = PyFloat_FromDouble(cNum);

	return pNum;
}

PyObject* rtopFalse()
{
	Py_RETURN_FALSE;
}

PyObject* rtopTrue()
{
	Py_RETURN_TRUE;
}

PyObject* rtopSymbol(VALUE rSymbol)
{
	PyObject* pString;
	char* cStr;

	cStr = STR2CSTR(rb_funcall(rSymbol, rb_intern("to_s"), 0));
	pString = PyString_FromString(cStr);

	return pString;

}

PyObject* rtopObject(VALUE rObj, int is_key)
{
	// The above is_key parameter determines whether the object
	// created show be immutable if possible

	PyObject *pObj;
	VALUE rInspect;

	// Check the object for its type and apply the appropriate
	// conversion function

	switch(TYPE(rObj))
	{
		case T_STRING:
			pObj = rtopString(rObj);
			break;
			
		case T_ARRAY:
			// If this object is going to be used as a
			// hash key we should make it a tuple instead
			// of a list
			if(is_key) pObj = rtopArrayToTuple(rObj);
			else
			{
				pObj = rtopArrayToList(rObj);
			}
			break;
			
		case T_HASH:
			pObj = rtopHash(rObj);
			break;
		
		case T_FIXNUM:
			pObj = rtopFixnum(rObj);
			break;
		
		case T_BIGNUM:
			pObj = rtopBignum(rObj);
			break;
		
		case T_FLOAT:
			pObj = rtopFloat(rObj);
			break;
			
		case T_NIL:
			pObj = Py_None;
			break;
			
		case T_TRUE:
			pObj = rtopTrue();
			break;
			
		case T_FALSE:
			pObj = rtopFalse();
			break;
		
		case T_SYMBOL:
			pObj = rtopSymbol(rObj);
			break;
		
		default:
			if(rb_obj_is_kind_of(rObj, cRbPyObj) == Qtrue)
			{
				// rObj is a wrapped python object. We
				// just take the object it wraps. In
				// this case we are effectively passing
				// a python object by reference
				pObj = rpObjectGetPyObject(rObj);
			}
			else
			{
				// If we can't figure out what else to
				// do with the ruby object we just pass
				// a string representation of it
				rInspect = rb_inspect(rObj);
				pObj = rtopString(rInspect);
			}
	}

	return pObj;
}
