#include "config.h"
#include "ptor.h"
#include "rtop.h"
#include "bridge.h"

#ifndef _RBPY_OBJECT_H_
#define _RBPY_OBJECT_H_

struct RubyPyObj 
{
	PyObject* pObject;
};

typedef struct RubyPyObj PObj;

void rp_obj_mark(PObj* self);

void rp_obj_free(PObj* self);

VALUE rp_obj_alloc(VALUE klass);


//pymod
VALUE pymod_init(VALUE self,VALUE mname);

int pymod_has_func(VALUE self,ID func_hame);
VALUE rp_pymod_call_func(VALUE self,VALUE func_name,VALUE args);

VALUE pymod_delegate(VALUE self,VALUE args);

VALUE pymod_getclasses(PyObject *pModule);rp_obj

VALUE pymod_classdelegate(VALUE self, VALUE klass);

VALUE pycla_from_class(PyObject *pClass);

#endif /* _RBPY_OBJECT_H_ */
