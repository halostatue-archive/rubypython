#include "config.h"

#ifndef _RP_UTIL_H_
#define _RP_UTIL_H_
int rpSymbolIsSetter();

int rpSymbolIsDoubleBang(VALUE);

VALUE rpObjectWrap(PyObject*);

#endif /* _RP_UTIL_H_ */
