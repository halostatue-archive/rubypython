#include "rp_object.h"
#include "stdio.h"

#include "rp_rubypyobj.h"

RUBY_EXTERN VALUE mRubyPythonBridge;
RUBY_EXTERN VALUE ePythonError;
RUBY_EXTERN VALUE cRubyPyObject;
RUBY_EXTERN VALUE cBlankObject;
RUBY_EXTERN VALUE cRubyPyClass;

VALUE cRubyPyModule;
VALUE cRubyPyFunction;
VALUE cRubyPyInstance;


VALUE rp_inst_from_instance(PyObject* pInst)
{
	PObj* self;
	VALUE rInst = rb_class_new_instance(0, NULL, cRubyPyInstance);
	PyObject *pClassDict,*pClass,*pInstDict;
	VALUE rInstDict, rClassDict;
	Data_Get_Struct(rInst, PObj, self);
	self->pObject = pInst;
	pClass = PyObject_GetAttrString(pInst,"__class__");
	pClassDict = PyObject_GetAttrString(pClass,"__dict__");
	pInstDict = PyObject_GetAttrString(pInst,"__dict__");
	Py_XINCREF(pClassDict);
	Py_XINCREF(pInstDict);
	rClassDict = rp_obj_from_pyobject(pClassDict);
	rInstDict = rp_obj_from_pyobject(pInstDict);
	rb_iv_set(rInst,"@pclassdict", rClassDict);
	rb_iv_set(rInst,"@pinstdict", rInstDict);
	return rInst;
}

VALUE rp_inst_attr_set(VALUE self, VALUE args)
{
	VALUE name, name_string, rClassDict, result, rInstDict;
	VALUE ret;
	int instance;
	char* cname;
	PObj *pClassDict,*pInstDict,*pDict;
	PyObject* pName;
	name = rb_ary_shift(args);
	name_string = rb_funcall(name, rb_intern("to_s"), 0);
	rb_funcall(name_string, rb_intern("chop!"), 0);	
	if(!rp_has_attr(self, name_string))
	{		
		int argc;		
		VALUE* argv;
		argc = RARRAY_LEN(args);
		argv = ALLOC_N(VALUE, argc);
		MEMCPY(argv, RARRAY_PTR(args), VALUE, argc);
		return rb_call_super(argc, argv);
	}
	
	cname = STR2CSTR(name_string);
	
	if((NUM2INT(rb_funcall(args, rb_intern("size"), 0)) == 1))
	{
		args = rb_ary_entry(args, 0);
	}
	
		
	rClassDict = rb_iv_get(self,"@pclassdict");
	rInstDict = rb_iv_get(self,"@pinstdict");
	
	Data_Get_Struct(rClassDict, PObj, pClassDict);
	Data_Get_Struct(rInstDict, PObj, pInstDict);
	pName = PyString_FromString(cname);
	if(PyDict_Contains(pInstDict->pObject, pName))
	{
		pDict = pInstDict;

	}
	else
	{
		pDict = pClassDict;
		
	}
	Py_XDECREF(pName);
	PyDict_SetItemString(pDict->pObject, STR2CSTR(name_string), rtop_obj(args, 0));
	return Qtrue;
}

//:nodoc:
VALUE rp_inst_delegate(VALUE self, VALUE args)
{
	VALUE name, name_string, rClassDict, result, rInstDict;
	VALUE ret;
	char* cname;
	PObj *pClassDict,*pInstDict;
	PyObject* pCalled;
	
	if(rp_equal(args))
	{
		return rp_inst_attr_set(self, args);
	}
	if(!rp_has_attr(self, rb_ary_entry(args, 0)))
	{		
		int argc;
		
		VALUE* argv;
		argc = RARRAY_LEN(args);
		argv = ALLOC_N(VALUE, argc);
		MEMCPY(argv, RARRAY_PTR(args), VALUE, argc);
		return rb_call_super(argc, argv);
	}
	name = rb_ary_shift(args);
	name_string = rb_funcall(name, rb_intern("to_s"), 0);
	cname = STR2CSTR(name_string);
		
	rClassDict = rb_iv_get(self,"@pclassdict");
	rInstDict = rb_iv_get(self,"@pinstdict");
	Data_Get_Struct(rClassDict, PObj, pClassDict);
	Data_Get_Struct(rInstDict, PObj, pInstDict);
	pCalled = PyDict_GetItemString(pInstDict->pObject, cname);
	if(!pCalled)
	{
		pCalled = PyDict_GetItemString(pClassDict->pObject, cname);
	}
	Py_XINCREF(pCalled);
	result = rpPyToRbObjectKeep(pCalled);
	if(rb_obj_is_instance_of(result, cRubyPyFunction))
	{
		Py_XINCREF(rp_obj_pobject(self));
		rb_ary_unshift(args, self);
		ret = rpCall(pCalled, args);
		return ret;
	}
	return result;
	
}




VALUE rp_func_from_function(PyObject *pFunc)
{
	PObj* self;
	VALUE rFunc = rb_class_new_instance(0, NULL, cRubyPyFunction);
	Data_Get_Struct(rFunc, PObj, self);
	self->pObject = pFunc;
	return rFunc;
}

VALUE rp_obj_wrap(PyObject* pObj)
{
	VALUE rObj;
	if(PyFunction_Check(pObj)||PyMethod_Check(pObj)||!PyObject_HasAttrString(pObj,"__dict__"))
	{
		return rp_func_from_function(pObj);

	}
	if(PyInstance_Check(pObj))
	{
		rObj = rp_inst_from_instance(pObj);
		return rObj;
	}
	return rp_cla_from_class(pObj);
}


// Not completely accurate
int rp_is_func(VALUE pObj)
{
	PObj* self;
	Data_Get_Struct(pObj, PObj, self);
	Py_XINCREF(self->pObject);
	return (PyFunction_Check(self->pObject)||PyMethod_Check(self->pObject));
}


int rp_equal(VALUE args)
{
	VALUE mname = rb_ary_entry(args, 0);
	VALUE name_string = rb_funcall(mname, rb_intern("to_s"), 0);
	return Qtrue == rb_funcall(name_string, rb_intern("end_with?"), 1, rb_str_new2("="));
}



int rp_double_bang(VALUE args)
{
	VALUE mname = rb_ary_entry(args, 0);
	VALUE name_string = rb_funcall(mname, rb_intern("to_s"), 0);
	return Qtrue == rb_funcall(name_string, rb_intern("end_with?"), 1, rb_str_new2("!!"));
}




// 
// A wrapper class for Python functions and methods.
// 
// This is used internally to aid RubyPyClass in delegating method calls.
// 

void Init_RubyPyFunction()
{
	cRubyPyFunction = rb_define_class_under(mRubyPythonBridge,"RubyPyFunction", cRubyPyObject);
}

void Init_RubyPyInstance()
{
	cRubyPyInstance = rb_define_class_under(mRubyPythonBridge,"RubyPyInstance", cRubyPyObject);
	rb_define_method(cRubyPyInstance,"method_missing", rp_inst_delegate,- 2);
}
