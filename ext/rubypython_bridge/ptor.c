#include "ptor.h"

VALUE ptor_string(PyObject* pString)
{
	if(!PyString_Check(pString)) return Qnil;
	
	char *cstr;
	cstr=malloc(PyString_Size(pString)*sizeof(char));
	strcpy(cstr,PyString_AsString(pString));
	return rb_str_new2(cstr);
}

VALUE ptor_list(PyObject* pList)
{
	if(!PyList_Check(pList)) return Qnil;
	VALUE rArray;
	VALUE rElement;
	PyObject* element;
	int i=0;
	
	rArray=rb_ary_new();
	int list_size=PyList_Size(pList);
	for(i=0;i<list_size;i++)
	{
		element=PyList_GetItem(pList,i);
		Py_INCREF(element);
		rElement=ptor_obj(element);
		rb_ary_push(rArray,rElement);
	}
	return rArray;
}

VALUE ptor_int(PyObject* pNum)
{
	VALUE rNum;
	if(!PyInt_Check(pNum)) return Qnil;
	rNum=INT2NUM(PyInt_AsLong(pNum));
	return rNum;
	
}

VALUE ptor_long(PyObject* pNum)
{
	VALUE rNum;
	long cNum;
	if(!PyLong_Check(pNum)) return Qnil;
	cNum=PyLong_AsLong(pNum);
	if(PyErr_ExceptionMatches(PyExc_OverflowError))
	{
		raise_PyError();
		return Qnil;
	}
	rNum=INT2NUM(cNum);
	return rNum;
	
}

VALUE ptor_float(PyObject* pNum)
{
	VALUE rNum;
	if(!PyFloat_Check(pNum)) return Qnil;
	rNum=rb_float_new(PyFloat_AsDouble(pNum));
	return rNum;
}

VALUE ptor_tuple(PyObject* pTuple)
{
	VALUE rArray;
	PyObject* pList;
	if(!PyTuple_Check(pTuple)) return Qnil;
	pList=PySequence_List(pTuple);
	rArray=ptor_list(pList);
	Py_DECREF(pList);
	return rArray;
}


VALUE ptor_dict(PyObject* pDict)
{
	VALUE rHash;
	if(!PyDict_Check(pDict)) return Qnil;
	rHash=rb_hash_new();
	PyObject *key,*val;
	Py_ssize_t pos=0;
	VALUE rKey,rVal;
	while(PyDict_Next(pDict,&pos,&key,&val))
	{
		Py_XINCREF(key);
		Py_XINCREF(val);
		rKey=ptor_obj(key);
		rVal=ptor_obj(val);
		if(rKey==Qnil) continue;
		rb_hash_aset(rHash,rKey,rVal);
	}
	return rHash;
}

VALUE ptor_obj(PyObject* pObj)
{
	VALUE rObj;
	if(PyObject_TypeCheck(pObj,&PyString_Type))
	{
		rObj=ptor_string(pObj);
		Py_DECREF(pObj);
		return rObj;
	}
	
	if(PyObject_TypeCheck(pObj,&PyList_Type))
	{
		rObj=ptor_list(pObj);
		Py_DECREF(pObj);
		return rObj;
	}
	if(PyObject_TypeCheck(pObj,&PyInt_Type))
	{
		rObj=ptor_int(pObj);
		Py_DECREF(pObj);
		return rObj;
	}
	if(PyObject_TypeCheck(pObj,&PyLong_Type))
	{
		rObj=ptor_long(pObj);
		Py_DECREF(pObj);
		return rObj;
	}
	if(PyObject_TypeCheck(pObj,&PyFloat_Type))
	{
		rObj=ptor_float(pObj);
		Py_DECREF(pObj);
		return rObj;
	}
	if(PyObject_TypeCheck(pObj,&PyTuple_Type))
	{
		rObj=ptor_tuple(pObj);
		Py_DECREF(pObj);
		return rObj;
	}
	if(PyObject_TypeCheck(pObj,&PyDict_Type))
	{
		rObj=ptor_dict(pObj);
		Py_DECREF(pObj);
		return rObj;
	}
	// if(PyFunction_Check(pObj)||PyMethod_Check(pObj))
	// {
	// 	return rp_obj_from_pyobject(pObj);
	// }
	if(pObj==Py_True)
	{
		Py_DECREF(Py_True);
		return Qtrue;
	}
	if(pObj==Py_False)
	{
		Py_DECREF(Py_False);
		return Qfalse;
	}
	if(pObj==Py_None)
	{
		return Qnil;
	}
	// return rp_cla_from_class(pObj);	
	PyObject* pRepr;
	pRepr=PyObject_Repr(pObj);
	Py_XDECREF(pObj);
	rObj=ptor_string(pRepr);
	Py_XDECREF(pRepr);
	return rObj;
}

