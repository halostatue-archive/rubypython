#include "config.h"
#include "ptor.h"
#include "rtop.h"
#include "cbridge.h"
#include "rp_rubypyobj.h"
#include "rp_blankobject.h"
#include "rp_rubypymod.h"

#ifndef _RP_RUBYPYCLASS_H_
#define _RP_RUBYPYCLASS_H_

VALUE rp_cla_from_class(PyObject*);

VALUE rp_cla_new_inst(VALUE, VALUE);


#endif