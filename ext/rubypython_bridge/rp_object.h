#include "config.h"

#ifndef _RP_OBJECT_H_
#define _RP_OBJECT_H_
VALUE rpInstanceFromPyObject(PyObject*);

int rpSymbolIsSetter();

int rpSymbolIsDoubleBang(VALUE);

VALUE rpObjectWrap(PyObject*);

#endif /* _RP_OBJECT_H_ */
