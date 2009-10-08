#include "rp_rubypymod.h"

VALUE cRubyPyModule;

RUBY_EXTERN VALUE mRubyPythonBridge;
RUBY_EXTERN VALUE cRubyPyFunction;
RUBY_EXTERN VALUE cRubyPyClass;
RUBY_EXTERN VALUE cRubyPyObject;

VALUE rp_mod_call_func(VALUE self, VALUE func_name, VALUE args)
{
	PObj* cself;
	Data_Get_Struct(self, PObj, cself);
	PyObject *pModule,*pFunc;
	VALUE rReturn;
	
	pModule = cself->pObject;
	pFunc = rp_get_func_with_module(pModule, func_name);
	rReturn = rp_call_func(pFunc, args);
	Py_XDECREF(pFunc);
	
	return rReturn;
	
}




//:nodoc:
VALUE rp_mod_init(VALUE self, VALUE mname)
{
	PObj* cself;
	Data_Get_Struct(self, PObj, cself);
	cself->pObject = rp_get_module(mname);
	VALUE rDict;
	PyObject *pModuleDict;
	pModuleDict = PyModule_GetDict(cself->pObject);
	Py_XINCREF(pModuleDict);
	rDict = rp_obj_from_pyobject(pModuleDict);
	rb_iv_set(self,"@pdict", rDict);
	return self;
}


VALUE rp_mod_attr_set(VALUE self, VALUE args)
{
	VALUE rDict;
	PObj *pDict;
	VALUE mname = rb_ary_shift(args);
	VALUE name_string = rb_funcall(mname, rb_intern("to_s"), 0);
	rb_funcall(name_string, rb_intern("chop!"), 0);
	if(!rp_has_attr(self, name_string))
	{		
		int argc;
		
		VALUE *argv;
		argc = RARRAY_LEN(args);
		argv = ALLOC_N(VALUE, argc);
		MEMCPY(argv, RARRAY_PTR(args), VALUE, argc);
		return rb_call_super(argc, argv);
	}
	if(NUM2INT(rb_funcall(args, rb_intern("size"), 0)) == 1)
	{
		args = rb_ary_entry(args, 0);
	}
	rDict = rb_iv_get(self,"@pdict");
	Data_Get_Struct(rDict, PObj, pDict);
	PyDict_SetItemString(pDict->pObject, STR2CSTR(name_string), rtop_obj(args, 0));
	return Qtrue;
}

//:nodoc:
VALUE rp_mod_delegate(VALUE self, VALUE args)
{
	VALUE name, name_string, rDict, result;
	VALUE ret;
	PObj *pDict;
	PyObject *pCalled;
	if(rp_equal(args))
	{
		return rp_mod_attr_set(self, args);
	}
	// if(rp_double_bang)
	// {
	// 	return rp_mod_attr_db(args);
	// }
	if(!rp_has_attr(self, rb_ary_entry(args, 0)))
	{		
		int argc;
		
		VALUE *argv;
		argc = RARRAY_LEN(args);
		argv = ALLOC_N(VALUE, argc);
		MEMCPY(argv, RARRAY_PTR(args), VALUE, argc);
		return rb_call_super(argc, argv);
	}
	name = rb_ary_shift(args);
	name_string = rb_funcall(name, rb_intern("to_s"), 0);
		
	rDict = rb_iv_get(self,"@pdict");
	Data_Get_Struct(rDict, PObj, pDict);
	pCalled = PyDict_GetItemString(pDict->pObject, STR2CSTR(name_string));
	Py_XINCREF(pCalled);
	result = ptor_obj_no_destruct(pCalled);
	if(rb_obj_is_instance_of(result, cRubyPyFunction))
	{
		ret = rp_call_func(pCalled, args);
		return ret;
	}
	else if(rb_obj_is_instance_of(result, cRubyPyClass)&&(rb_funcall(args, rb_intern("empty?"), 0) == Qfalse)&&PyCallable_Check(pCalled))
	{
		ret = rp_call_func(pCalled, args);
		return ret;
	}
	return result;
	
}


/*
A wrapper class for Python Modules.

Methods calls are delegated to the equivalent Python methods / functions. Attribute references
return either the equivalent attribute converted to a native Ruby type, or wrapped reference 
to a Python object. RubyPyModule instances should be created through the use of RubyPython.import.

*/
void Init_RubyPyModule()
{
	cRubyPyModule = rb_define_class_under(mRubyPythonBridge,"RubyPyModule", cRubyPyObject);
	rb_define_method(cRubyPyModule,"initialize", rp_mod_init, 1);
	rb_define_method(cRubyPyModule,"method_missing", rp_mod_delegate,- 2);
}