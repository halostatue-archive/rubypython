#include "rp_rubypyclass.h"

#include "rp_rubypymod.h"
#include "rp_rubypyobj.h"

RUBY_EXTERN VALUE mRubyPythonBridge;
RUBY_EXTERN VALUE ePythonError;
RUBY_EXTERN VALUE cRubyPyObject;
RUBY_EXTERN VALUE cBlankObject;

VALUE cRubyPyClass;

VALUE rpClassFromPyObject(PyObject *pClass)
{
	PObj* self;
	PyObject* pClassDict;
	VALUE rDict;
	VALUE rClass = rb_class_new_instance(0, NULL, cRubyPyClass);

	Data_Get_Struct(rClass, PObj, self);
	self->pObject = pClass;
	
	pClassDict = PyObject_GetAttrString(pClass,"__dict__");
	Py_XINCREF(pClassDict);
	
	rDict = rpObjectFromPyObject
(pClassDict);
	rb_iv_set(rClass,"@pdict", rDict);
	
	return rClass;
}

static
VALUE rpClassNew(VALUE self, VALUE args)
{
	PyObject* pSelf;

	pSelf = rpObjectUnwrap(self);
	
	return rpCall(pSelf, args);
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
	rb_define_method(cRubyPyClass,"method_missing", rpModuleDelagate,- 2);
	rb_define_method(cRubyPyClass,"new", rpClassNew,- 2);
}