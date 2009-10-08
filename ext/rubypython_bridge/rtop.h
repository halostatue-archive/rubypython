#include "config.h"
#include "rp_error.h"

#ifndef _RTOP_H_
#define _RTOP_H_
PyObject* rtop_string(VALUE);
PyObject* rtop_array_list(VALUE);
PyObject* rtop_array_tuple(VALUE);
PyObject* rtop_hash(VALUE);
PyObject* rtop_fixnum(VALUE);
PyObject* rtop_bignum(VALUE);
PyObject* rtop_float(VALUE);
PyObject* rtop_false(void);
PyObject* rtop_true(void);
PyObject* rtop_symbol(VALUE);
PyObject* rtop_obj(VALUE, int);

#endif /* _RTOP_H_ */
