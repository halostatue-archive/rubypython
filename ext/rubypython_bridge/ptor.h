#include "config.h"

#ifndef _PTOR_H_
#define _PTOR_H_
	
//Python to Ruby Conversion
VALUE ptor_string(PyObject* pString);

VALUE ptor_list(PyObject* pList);

VALUE ptor_obj(PyObject* pObj);

VALUE ptor_int(PyObject* pNum);

VALUE ptor_long(PyObject* pNum);

VALUE ptor_float(PyObject* pNum);

VALUE ptor_tuple(PyObject* pTuple);

VALUE ptor_dict(PyObject* pDict);



#endif /* _PTOR_H_ */
