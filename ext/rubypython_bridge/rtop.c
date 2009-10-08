#include "rtop.h"

RUBY_EXTERN VALUE cRubyPyObject;
RUBY_EXTERN PyObject* rp_obj_pobject(VALUE self);

/*
*  Note: For the builtin types rubypython creates a copy of the ruby
*  object to pass into python. Builtin types are passed by VALUE not
*  by REFERENCE.
*/

PyObject* rtop_string(VALUE rString)
{

	PyObject* pString;
	char *cString;
	char *cStringCopy;

	cString = STR2CSTR(rString);
	cStringCopy = malloc(strlen(cString) * sizeof(char));
	strcpy(cStringCopy, cString);

	pString = PyString_FromString(cStringCopy);

	return pString;
}


PyObject* rtop_array_list(VALUE rArray)
{
	PyObject* pList;
	int i;
	int size = RARRAY_LEN(rArray);

	pList = PyList_New(size);

	for(i = 0; i < size; i++)
	{
		PyList_SetItem(pList, i, rtop_obj(rb_ary_entry(rArray, i), 0));
	}

	return pList;
}

PyObject* rtop_array_tuple(VALUE rArray)
{
	PyObject *pTuple,*pList;

	pList = rtop_array_list(rArray);
	pTuple = PySequence_Tuple(pList);
	Py_XDECREF(pList);

	return pTuple;
}

PyObject* rtop_hash(VALUE rHash)
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
		PyDict_SetItem(pDict, rtop_obj(rKey, 1), rtop_obj(rVal, 0));
	}

	return pDict;
}

PyObject* rtop_fixnum(VALUE rNum)
{
	PyObject* pNum;
	long cNum;

	cNum = NUM2LONG(rNum);
	pNum = PyInt_FromLong(cNum);

	return pNum;
}

PyObject* rtop_bignum(VALUE rNum)
{
	PyObject* pNum;
	long cNum;

	cNum = NUM2LONG(rNum);
	pNum = PyLong_FromLong(cNum);

	return pNum;
}

PyObject* rtop_float(VALUE rNum)
{
	PyObject* pNum;
	double cNum;

	cNum = NUM2DBL(rNum);
	pNum = PyFloat_FromDouble(cNum);

	return pNum;
}

PyObject* rtop_false()
{
	Py_RETURN_FALSE;
}

PyObject* rtop_true()
{
	Py_RETURN_TRUE;
}

PyObject* rtop_symbol(VALUE rSymbol)
{
	PyObject* pString;
	char* cStr;

	cStr = STR2CSTR(rb_funcall(rSymbol, rb_intern("to_s"), 0));
	pString = PyString_FromString(cStr);

	return pString;

}

PyObject* rtop_obj(VALUE rObj, int is_key)
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
			pObj = rtop_string(rObj);
			break;
			
		case T_ARRAY:
			// If this object is going to be used as a
			// hash key we should make it a tuple instead
			// of a list
			if(is_key) pObj = rtop_array_tuple(rObj);
			else
			{
				pObj = rtop_array_list(rObj);
			}
			break;
			
		case T_HASH:
			pObj = rtop_hash(rObj);
			break;
		
		case T_FIXNUM:
			pObj = rtop_fixnum(rObj);
			break;
		
		case T_BIGNUM:
			pObj = rtop_bignum(rObj);
			break;
		
		case T_FLOAT:
			pObj = rtop_float(rObj);
			break;
			
		case T_NIL:
			pObj = Py_None;
			break;
			
		case T_TRUE:
			pObj = rtop_true();
			break;
			
		case T_FALSE:
			pObj = rtop_false();
			break;
		
		case T_SYMBOL:
			pObj = rtop_symbol(rObj);
			break;
		
		default:
			if(rb_obj_is_kind_of(rObj, cRubyPyObject) == Qtrue)
			{
				// rObj is a wrapped python object. We
				// just take the object it wraps. In
				// this case we are effectively passing
				// a python object by reference
				pObj = rp_obj_pobject(rObj);
			}
			else
			{
				// If we can't figure out what else to
				// do with the ruby object we just pass
				// a string representation of it
				rInspect = rb_inspect(rObj);
				pObj = rtop_string(rInspect);
			}
	}

	return pObj;
}
