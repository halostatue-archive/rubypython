#include "rp_function.h"
#include "rp_object.h"

RUBY_EXTERN VALUE mRubyPythonBridge;
RUBY_EXTERN VALUE cRubyPyObject;

VALUE cRubyPyFunction;

VALUE rpFunctionFromPyObject(PyObject *pFunc)
{
	PObj* self;
	VALUE rFunc = rb_class_new_instance(0, NULL, cRubyPyFunction);
	
	Data_Get_Struct(rFunc, PObj, self);
	
	self->pObject = pFunc;
	
	return rFunc;
}


// 
// A wrapper class for Python functions and methods.
// 
// This is used internally to aid RubyPyClass in delegating method calls.
// 

inline void Init_RubyPyFunction()
{
	cRubyPyFunction = rb_define_class_under(mRubyPythonBridge,"RubyPyFunction", cRubyPyObject);
}
