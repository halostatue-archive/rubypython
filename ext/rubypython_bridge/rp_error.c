#include "rp_error.h"

VALUE ePythonError;
VALUE eRubyPyError;

void rpPythonError()
{
	PyObject *pType,*pValue,*pTraceback;
	PyObject *pTypeName;
	
	PyErr_Fetch(&pType,&pValue,&pTraceback);
	
	pTypeName = PyObject_GetAttrString(pType,"__name__");
	Py_XDECREF(pType);
	
	rb_raise(ePythonError,"%s:(%s)\n", STR2CSTR(ptorObject(pTypeName)), STR2CSTR(rb_inspect(ptorObject(pValue))));
	
	Py_XDECREF(pTraceback);
}

void rpRubyPyError(char* eString) {
	rb_raise(eRubyPyError, eString);
}

/*
Used to pass error information back into Ruby should an error occur in the embedded Python
interpreter.
*/
void Init_RubyPyError()
{
	ePythonError = rb_define_class("PythonError", rb_eException);
	eRubyPyError = rb_define_class("RubyPyError", rb_eException);
}