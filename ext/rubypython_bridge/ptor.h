#include "config.h"
#include "rp_error.h"


#ifndef _PTOR_H_
#define _PTOR_H_
	
//Python to Ruby Conversion
VALUE rpPyToRbString(PyObject* pString);

VALUE rpPyToRbList(PyObject* pList);

VALUE rpPyToRbObject(PyObject* pObj);

VALUE rpPyToRbInt(PyObject* pNum);

VALUE rpPyToRbLong(PyObject* pNum);

VALUE rpPyToRbFloat(PyObject* pNum);

VALUE rpPyToRbTuple(PyObject* pTuple);

VALUE rpPyToRbDict(PyObject* pDict);

VALUE rpPyToRbObjectKeep(PyObject *pObj);



#endif /* _PTOR_H_ */
