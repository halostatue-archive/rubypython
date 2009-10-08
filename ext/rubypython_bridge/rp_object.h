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

void rp_obj_mark(PObj*);

void rp_obj_free(PObj*);

VALUE rp_obj_alloc(VALUE);

PyObject* rp_obj_pobject(VALUE);

VALUE rp_obj_name(VALUE);


// Ruby wrapper for Python Modules
VALUE rp_mod_init(VALUE, VALUE);

int rp_has_attr(VALUE, ID);

VALUE rp_mod_call_func(VALUE, VALUE, VALUE);

VALUE rp_mod_delegate(VALUE, VALUE);

// Ruby wrapper for Python classes

VALUE rp_cla_from_class(PyObject*);

VALUE rp_func_from_function(PyObject*);

int rp_is_func(VALUE pObj);

VALUE rp_obj_from_pyobject(PyObject*);

VALUE rp_inst_from_instance(PyObject*);

VALUE rp_inst_delegate(VALUE, VALUE);

VALUE rp_cla_new_inst(VALUE, VALUE);

VALUE rp_obj_responds(VALUE, VALUE);

VALUE blank_undef_if(VALUE, VALUE);

VALUE blank_obj_prep(VALUE);

int rp_equal();

int rp_double_bang(VALUE);

VALUE rp_mod_attr_set(VALUE, VALUE);

VALUE rp_inst_attr_set(VALUE, VALUE);

VALUE rp_obj_wrap(PyObject*);

#endif /* _RP_OBJECT_H_ */
