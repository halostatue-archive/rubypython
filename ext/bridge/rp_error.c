#include "rp_error.h"

VALUE ePythonError;

void rp_pythonerror()
{
	rb_raise(ePythonError);
	PyErr_Clear();
}
void Init_RubyPyError()
{
	ePythonError=rb_define_class("PythonError",rb_eException);
}