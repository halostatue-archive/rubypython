#include "rp_class.h"

#include "rp_module.h"
#include "rp_object.h"

RUBY_EXTERN VALUE mRubyPythonBridge;
RUBY_EXTERN VALUE ePythonError;
RUBY_EXTERN VALUE cRbPyObj;
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

	pSelf = rpObjectGetPyObject(self);
	
	return rpCall(pSelf, args);
}

/*
A wrapper class for Python classes and instances.

This allows objects which cannot easily be converted to native Ruby types to still be accessible
from within ruby. Most users need not concern themselves with anything about this class except
its existence.

*/
inline void Init_RubyPyClass()
{
	cRubyPyClass = rb_define_class_under(mRubyPythonBridge,"RubyPyClass", cRbPyObj);
	rb_define_method(cRubyPyClass,"method_missing", rpModuleDelegate,- 2);
	rb_define_method(cRubyPyClass,"new", rpClassNew,- 2);
}
