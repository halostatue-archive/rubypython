#include "config.h"
#include "ptor.h"
#include "rtop.h"
#include "cbridge.h"
#include "rp_error.h"

#ifndef _RP_OBJECT_H_
#define _RP_OBJECT_H_

typedef struct RubyPyObj 
{
	PyObject* pObject;
} PObj;

PyObject* rpObjectGetPyObject(VALUE);

VALUE rpObjectFromPyObject(PyObject*);

int rpHasSymbol(VALUE, ID);

VALUE rpRespondsTo(VALUE, VALUE);
#endif