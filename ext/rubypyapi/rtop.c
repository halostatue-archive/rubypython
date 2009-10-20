#include "rtop.h"

RUBY_EXTERN VALUE cRubyPyObject;
RUBY_EXTERN PyObject* rpObjectGetPyObject(VALUE self);

/* Convert Builtin types */

PyObject* rtopString(VALUE rString)
{

	PyObject* pString;
	char* cString;
	char* cStringCopy;

	cString = STR2CSTR(rString);
	cStringCopy = malloc(strlen(cString) * sizeof(char));
	strcpy(cStringCopy, cString);

	pString = PyString_FromString(cStringCopy);

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
	PyObject *pDict,*pKey,*pVal;
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

PyObject* rtopObject(VALUE rObj)
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
			Py_INCREF(Py_None);
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
			pObj = Py_None;
			Py_INCREF(Py_None);
			break;
	return pObj;
}
