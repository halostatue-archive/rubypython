#include "py_error.h"
#include "py_object.h"

VALUE ePythonError;
VALUE eRubyPyError;

void rpPythonError() {
	PyObject *pType,*pValue,*pTraceback;
	PyObject *pTypeName;
	
	PyErr_Fetch(&pType,&pValue,&pTraceback);
	
	pTypeName = PyObject_GetAttrString(pType,"__name__");
	Py_XDECREF(pType);
	
	rb_raise(ePythonError,"%s:(%s)\n", STR2CSTR(ptorObject(pTypeName)), STR2CSTR(rb_inspect(ptorObject(pValue))));
	
	Py_XDECREF(pTraceback);
}

static
VALUE rpFetch(VALUE klass, VALUE rbType, VALUE rbValue, VALUE rbTraceback) {
	PyStruct *cType, *cValue, *cTraceback;
	
	Data_Get_Struct(rbType, PyStruct, cType);
	Data_Get_Struct(rbValue, PyStruct, cValue);
	Data_Get_Struct(rbTraceback, PyStruct, cTraceback);
	
	Py_XDECREF(cType->pObject);
	Py_XDECREF(cValue->pObject);
	Py_XDECREF(cTraceback->pObject);
	
	PyErr_Fetch(&(cType->pObject), &(cValue->pObject), &(cTraceback->pObject));
	return Qtrue;
}

static
VALUE rpClear(VALUE klass) {
  PyErr_Clear();
  return Qtrue;
}

static
VALUE rpErrorOccurred(VALUE klass) {
  if(PyErr_Occurred())
    return Qtrue;
  else
    return Qfalse;
}

/*
Used to pass error information back into Ruby should an error occur in the embedded Python
interpreter.
*/
inline
void Init_RubyPyError()
{
	ePythonError = rb_define_class("PythonError", rb_eException);
	rb_define_module_function(ePythonError, "fetch", &rpFetch, 3);
	rb_define_module_function(ePythonError, "error?", &rpErrorOccurred, 0);
	rb_define_module_function(ePythonError, "clear", &rpClear, 0);
}
