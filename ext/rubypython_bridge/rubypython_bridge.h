#include "config.h"

#ifndef RUBY_19
#ifndef RARRAY_LEN
#define RARRAY_LEN(arr) (RARRAY(arr)->len)
#define RARRAY_PTR(arr) (RARRAY(arr)->ptr)
#endif
#endif


#include "ptor.h" //PyObject to VALUE conversion
#include "rtop.h" //VALUE to PyObject conversion
#include "cbridge.h" //General interface functions
#include "rp_error.h" //Error propogation from Python to Ruby
#include "rp_object.h"
