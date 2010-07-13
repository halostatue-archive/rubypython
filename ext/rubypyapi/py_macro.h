#ifndef __PY_MACRO_H_
#define __PY_MACRO_H_
#include "config.h"

int rpPyString_mCheck(PyObject*);
int rpPyList_mCheck(PyObject*);
int rpPyTuple_mCheck(PyObject*);
int rpPyInt_mCheck(PyObject*);
int rpPyLong_mCheck(PyObject*);
int rpPyFloat_mCheck(PyObject*);
int rpPyDict_mCheck(PyObject*);
int rpPyObject_mTypeCheck(PyObject*, PyTypeObject*);
PyObject* rpPy_mTrue();
PyObject* rpPy_mRETURN_TRUE();
PyObject* rpPy_mFalse();
PyObject* rpPy_mRETURN_FALSE();
PyObject* rpPy_mNone();
void rpPy_mXINCREF(PyObject*);
void rpPy_mXDECREF(PyObject*);

#endif
