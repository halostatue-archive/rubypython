#include "config.h"

#ifndef _RP_RUBYPYMOD_H_
#define _RP_RUBYPYMOD_H_

// Ruby wrapper for Python Modules
VALUE rp_mod_init(VALUE, VALUE);

VALUE rp_mod_call_func(VALUE, VALUE, VALUE);

VALUE rp_mod_delegate(VALUE, VALUE);

VALUE rp_mod_attr_set(VALUE, VALUE);

#endif