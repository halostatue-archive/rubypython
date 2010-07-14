#include "py_macro.h"

int rpPyCallable_mCheck(PyObject* obj) {
        return PyCallable_Check(obj);
}

int rpPyObject_mTypeCheck(PyObject* obj, PyTypeObject* type) {
	return PyObject_TypeCheck(obj, type);
}

PyObject* rpPy_mTrue() { 
	return Py_True;
}

PyObject* rpPy_mRETURN_TRUE() {
        Py_RETURN_TRUE;
}

PyObject* rpPy_mFalse() {
	return Py_False;
}

PyObject* rpPy_mRETURN_FALSE() {
        Py_RETURN_FALSE;
}

PyObject* rpPy_mNone() {
	return Py_None;
}

void rpPy_mXINCREF(PyObject* obj) {
	Py_XINCREF(obj);
}

void rpPy_mXDECREF(PyObject* obj) {
	Py_XDECREF(obj);
}


