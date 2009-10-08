#include "rp_rubypyclass.h"

RUBY_EXTERN VALUE mRubyPythonBridge;
RUBY_EXTERN VALUE ePythonError;
RUBY_EXTERN VALUE cRubyPyObject;
RUBY_EXTERN VALUE cBlankObject;

VALUE cRubyPyClass;

VALUE rp_cla_from_class(PyObject *pClass)
{
	PObj* self;
	VALUE rClass = rb_class_new_instance(0, NULL, cRubyPyClass);
	PyObject* pClassDict;
	VALUE rDict;
	Data_Get_Struct(rClass, PObj, self);
	self->pObject = pClass;
	pClassDict = PyObject_GetAttrString(pClass,"__dict__");
	Py_XINCREF(pClassDict);
	rDict = rp_obj_from_pyobject(pClassDict);
	rb_iv_set(rClass,"@pdict", rDict);
	return rClass;
}

VALUE rp_cla_new_inst(VALUE self, VALUE args)
{
	PyObject* pSelf;
	pSelf = rp_obj_pobject(self);
	return rp_call_func(pSelf, args);
}

/*
A wrapper class for Python classes and instances.

This allows objects which cannot easily be converted to native Ruby types to still be accessible
from within ruby. Most users need not concern themselves with anything about this class except
its existence.

*/
void Init_RubyPyClass()
{
	cRubyPyClass = rb_define_class_under(mRubyPythonBridge,"RubyPyClass", cRubyPyObject);
	rb_define_method(cRubyPyClass,"method_missing", rp_mod_delegate,- 2);
	rb_define_method(cRubyPyClass,"new", rp_cla_new_inst,- 2);
}