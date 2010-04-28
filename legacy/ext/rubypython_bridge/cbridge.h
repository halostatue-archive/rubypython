#include "config.h"

#ifndef _BRIDGE_H_
#define _BRIDGE_H_
int rpSafeStart();
void rpSafeStop(int);

VALUE rpCallWithModule(VALUE, VALUE, VALUE);
VALUE rpCall(PyObject*, VALUE);

PyObject* rpGetModule(VALUE);
PyObject* rpGetFunctionWithModule(PyObject*, VALUE);
#endif /* _BRIDGE_H_ */


