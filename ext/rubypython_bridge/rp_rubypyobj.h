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


void rp_obj_mark(PObj*);
void rp_obj_free(PObj*);

VALUE rp_obj_alloc(VALUE);

PyObject* rp_obj_pobject(VALUE);

VALUE rp_obj_from_pyobject(PyObject*);

VALUE rp_obj_name(VALUE);

int rp_has_attr(VALUE, ID);

VALUE rp_obj_responds(VALUE, VALUE);
#endif