#include "config.h"
#include "ptor.h"
#include "rtop.h"
#include "rp_error.h"

#ifndef _BRIDGE_H_
#define _BRIDGE_H_

int safe_start();

void safe_stop(int);


VALUE rp_call_func_with_module_name(VALUE, VALUE, VALUE);

PyObject* rp_get_module(VALUE);

PyObject* rp_get_func_with_module(PyObject*, VALUE);

VALUE rp_call_func(PyObject*, VALUE);


#endif /* _BRIDGE_H_ */


