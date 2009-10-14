#include "config.h"
#include "ptor.h"
#include "rtop.h"
#include "cbridge.h"
#include "rp_error.h"

#ifndef _RP_RUBYPYOBJ_H_
#define _RP_RUBYPYOBJ_H_

typedef struct RubyPyObj 
{
	PyObject* pObject;
} PObj;

PyObject* rpObjectUnwrap(VALUE);

VALUE rpObjectFromPyObject(PyObject*);

int rpHasSymbol(VALUE, ID);

VALUE rpRespondsTo(VALUE, VALUE);
#endif