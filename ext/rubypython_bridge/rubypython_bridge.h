#include "config.h"

#ifndef RUBY_19

#ifndef RARRAY_LEN
#define RARRAY_LEN(arr) (RARRAY(arr)->len)
#define RARRAY_PTR(arr) (RARRAY(arr)->ptr)
#endif

#endif
