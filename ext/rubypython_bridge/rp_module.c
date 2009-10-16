#include "rp_module.h"

#include "rp_object.h"
#include "rp_function.h"

VALUE cRubyPyModule;

RUBY_EXTERN VALUE mRubyPythonBridge;
RUBY_EXTERN VALUE cRubyPyFunction;
RUBY_EXTERN VALUE cRubyPyClass;
RUBY_EXTERN VALUE cRubyPyObject;

static
VALUE rpModuleCallFunction(VALUE self, VALUE func_name, VALUE args)
{
	PyObject *pModule,*pFunc;
	VALUE rReturn;
	
	pModule = rpObjectGetPyObject(self);
	
	pFunc = rpGetFunctionWithModule(pModule, func_name);
	rReturn = rpCall(pFunc, args);
	Py_XDECREF(pFunc);
	
	return rReturn;
	
}

//:nodoc:
static
VALUE rpModuleInit(VALUE self, VALUE mname)
{
	PObj* cself;
	VALUE rDict;
	PyObject *pModuleDict;
	
	Data_Get_Struct(self, PObj, cself);
	cself->pObject = rpGetModule(mname);
	
	pModuleDict = PyModule_GetDict(cself->pObject);
	Py_XINCREF(pModuleDict);
	
	rDict = rpObjectFromPyObject(pModuleDict);
	
	rb_iv_set(self,"@pdict", rDict);
	
	return self;
}

static
VALUE rpModuleSetAttr(VALUE self, VALUE args)
{
	VALUE rDict;
	PyObject* pDict;
	
	VALUE mname = rb_ary_shift(args);
	VALUE name_string = rb_funcall(mname, rb_intern("to_s"), 0);
	
	//The method name ends with "=" because it is a setter.
	//We must chop that off before we pass the string to python.
	rb_funcall(name_string, rb_intern("chop!"), 0);
	
	//The wrapped python object does not have method or attribute with the
	//request named. Check for it in the Ruby superclass.
	if(!rpHasSymbol(self, name_string))
	{		
		int argc;
		
		VALUE* argv;
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
	
	pDict = rpObjectGetPyObject(rDict);
	
	PyDict_SetItemString(pDict, STR2CSTR(name_string), rtopObject(args, 0));
	
	return Qtrue;
}

//:nodoc:
VALUE rpModuleDelegate(VALUE self, VALUE args)
{
	VALUE name, name_string, rDict, result;
	VALUE ret;
	PyObject *pCalled, *pDict;
	
	if(rpSymbolIsSetter(args))
	{
		return rpModuleSetAttr(self, args);
	}
	
	// if(rpSymbolIsDoubleBang)
	// {
	// 	return rp_mod_attr_db(args);
	// }
	if(!rpHasSymbol(self, rb_ary_entry(args, 0)))
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
	
	pDict = rpObjectGetPyObject(rDict);
	
	pCalled = PyDict_GetItemString(pDict, STR2CSTR(name_string));
	Py_XINCREF(pCalled);
	
	result = ptorObjectKeep(pCalled);
	
	if(rb_obj_is_instance_of(result, cRubyPyFunction))
	{
		ret = rpCall(pCalled, args);
		return ret;
	}
	else if(rb_obj_is_instance_of(result, cRubyPyClass)&&(rb_funcall(args, rb_intern("empty?"), 0) == Qfalse)&&PyCallable_Check(pCalled))
	{
		ret = rpCall(pCalled, args);
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
	rb_define_method(cRubyPyModule,"initialize", rpModuleInit, 1);
	rb_define_method(cRubyPyModule,"method_missing", rpModuleDelegate,- 2);
}