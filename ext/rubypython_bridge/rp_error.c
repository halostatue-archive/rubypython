#include "rp_error.h"

VALUE ePythonError;

void rp_pythonerror(PyObject* PyError)
{
	PyObject *pType,*pValue,*pTraceback;
	PyErr_Fetch(&pType,&pValue,&pTraceback);
	rb_raise(ePythonError,"(%s):(%s)\n",rb_inspect(ptor_object(pType)),rb_inspect(ptor_object(pValue)));
	Py_XDECREF(pType);
	Py_XDECREF(pValue);
	Py_XDECREF(pTraceback);
	PyErr_Clear();
}
void Init_RubyPyError()
{
	ePythonError=rb_define_class("PythonError",rb_eException);
}