#include "config.h"
#include "ptor.h"
#include "rtop.h"
#include "cbridge.h"

#ifndef _RP_OBJECT_H_
#define _RP_OBJECT_H_

struct RubyPyObj 
{
	PyObject* pObject;
};

typedef struct RubyPyObj PObj;

void rp_obj_mark(PObj* self);

void rp_obj_free(PObj* self);

VALUE rp_obj_alloc(VALUE klass);

PyObject* rp_obj_pobject(VALUE self);

VALUE rp_obj_name(VALUE self);


//Ruby wrapper for Python Modules
VALUE rp_mod_init(VALUE self,VALUE mname);

int rp_has_attr(VALUE self,ID func_hame);

VALUE rp_mod_call_func(VALUE self,VALUE func_name,VALUE args);

VALUE rp_mod_delegate(VALUE self,VALUE args);

//Ruby wrapper for Python classes

VALUE rp_cla_from_class(PyObject *pClass);

VALUE rp_func_from_function(PyObject *pFunc);

int rp_is_func(VALUE pObj);

VALUE rp_obj_from_pyobject(PyObject *pObj);

VALUE rp_inst_from_instance(PyObject *pInst);

VALUE rp_inst_delegate(VALUE self,VALUE args);

VALUE rp_cla_new_inst(VALUE self,VALUE args);

VALUE rp_obj_responds(VALUE self,VALUE mname);

VALUE blank_undef_if(VALUE mname,VALUE klass);

VALUE blank_obj_prep(VALUE self);


#endif /* _RP_OBJECT_H_ */
