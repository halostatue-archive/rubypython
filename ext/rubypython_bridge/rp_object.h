#include "config.h"
#include "ptor.h"
#include "rtop.h"
#include "cbridge.h"
#include "rp_rubypyobj.h"
#include "rp_blankobject.h"
#include "rp_rubypymod.h"

#ifndef _RP_OBJECT_H_
#define _RP_OBJECT_H_

VALUE rp_func_from_function(PyObject*);

int rp_is_func(VALUE pObj);


VALUE rp_inst_from_instance(PyObject*);

VALUE rp_inst_delegate(VALUE, VALUE);

int rp_equal();

int rp_double_bang(VALUE);

VALUE rp_inst_attr_set(VALUE, VALUE);

VALUE rp_obj_wrap(PyObject*);

#endif /* _RP_OBJECT_H_ */
