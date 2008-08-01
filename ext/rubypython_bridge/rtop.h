#include "config.h"

#ifndef _RTOP_H_
#define _RTOP_H_
PyObject* rtop_string(VALUE rString);
PyObject* rtop_array_list(VALUE rArray);
PyObject* rtop_array_tuple(VALUE rArray);
PyObject* rtop_hash(VALUE rHash);
PyObject* rtop_fixnum(VALUE rNum);
PyObject* rtop_bignum(VALUE rNum);
PyObject* rtop_float(VALUE rNum);
PyObject* rtop_false(void);
PyObject* rtop_true(void);
PyObject* rtop_symbol(VALUE rSymbol);


PyObject* rtop_obj(VALUE rObj,int is_key);

#endif /* _RTOP_H_ */
