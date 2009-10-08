#include "rp_error.h"

VALUE ePythonError;

void rp_pythonerror()
{
	PyObject *pType,*pValue,*pTraceback;
	PyObject *pTypeName;
	
	PyErr_Fetch(&pType,&pValue,&pTraceback);
	
	pTypeName = PyObject_GetAttrString(pType,"__name__");
	Py_XDECREF(pType);
	
	rb_raise(ePythonError,"%s:(%s)\n", STR2CSTR(rpPyToRbObject(pTypeName)), STR2CSTR(rb_inspect(rpPyToRbObject(pValue))));
	
	Py_XDECREF(pTraceback);
}

/*
Used to pass error information back into Ruby should an error occur in the embedded Python
interpreter.
*/
void Init_RubyPyError()
{
	ePythonError = rb_define_class("PythonError", rb_eException);
}