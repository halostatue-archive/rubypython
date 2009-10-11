#include "config.h"

#ifndef _PTOR_H_
#define _PTOR_H_
//Python to Ruby Conversion
VALUE ptorString(PyObject* pString);
VALUE ptorList(PyObject* pList);
VALUE ptorInt(PyObject* pNum);
VALUE ptorLong(PyObject* pNum);
VALUE ptorFloat(PyObject* pNum);
VALUE ptorTuple(PyObject* pTuple);
VALUE ptorDict(PyObject* pDict);
VALUE ptorObject(PyObject* pObj);
VALUE ptorObjectKeep(PyObject *pObj);
#endif /* _PTOR_H_ */
