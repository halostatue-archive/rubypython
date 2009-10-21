#include "config.h"

#ifndef _RTOP_H_
#define _RTOP_H_
PyObject* rtopString(VALUE);
PyObject* rtopArrayToList(VALUE);
PyObject* rtopArrayToTuple(VALUE);
PyObject* rtopHash(VALUE);
PyObject* rtopFixnum(VALUE);
PyObject* rtopBignum(VALUE);
PyObject* rtopFloat(VALUE);
PyObject* rtopFalse(void);
PyObject* rtopTrue(void);
PyObject* rtopSymbol(VALUE);
PyObject* rtopObject(VALUE, int);

#endif /* _RTOP_H_ */
