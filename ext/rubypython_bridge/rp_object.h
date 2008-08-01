#include "config.h"
#include "ptor.h"
#include "rtop.h"
#include "cbridge.h"

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


//Ruby wrapper for Python Modules
VALUE rp_mod_init(VALUE self,VALUE mname);

int rp_has_attr(VALUE self,ID func_hame);

VALUE rp_mod_call_func(VALUE self,VALUE func_name,VALUE args);

VALUE rp_mod_delegate(VALUE self,VALUE args);

VALUE rp_mod_getclasses(PyObject *pModule);

VALUE rp_mod_classdelegate(VALUE self, VALUE klass);

//Ruby wrapper for Python classes

VALUE rp_cla_from_class(PyObject *pClass);

int rp_is_func(VALUE pObj);

VALUE rp_newmod_delegate(VALUE self,VALUE args);

VALUE rp_newmod_init(VALUE self, VALUE mname);

VALUE rp_obj_from_pyobject(PyObject *pObj);

#endif /* _RBPY_OBJECT_H_ */
