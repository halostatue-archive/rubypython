#include "config.h"
#include "ptor.h"
#include "rtop.h"

#ifndef _BRIDGE_H_
#define _BRIDGE_H_

int safe_start();

void safe_stop(int here);


VALUE rp_call_func_with_module_name(VALUE module,VALUE name,VALUE args);

PyObject* rp_get_module(VALUE mname);

PyObject* rp_get_func_with_module(PyObject* pModule,VALUE name);

VALUE rp_call_func(PyObject* pFunc, VALUE args);


#endif /* _BRIDGE_H_ */


