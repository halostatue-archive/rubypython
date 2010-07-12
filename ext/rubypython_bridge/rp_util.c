#include "rp_util.h"

#include "rp_object.h"
#include "rp_function.h"
#include "rp_instance.h"
#include "rp_class.h"

RUBY_EXTERN VALUE mRubyPythonBridge;
RUBY_EXTERN VALUE ePythonError;
RUBY_EXTERN VALUE cRubyPyObject;
RUBY_EXTERN VALUE cBlankObject;
RUBY_EXTERN VALUE cRubyPyClass;
RUBY_EXTERN VALUE cRubyPyFunction;
RUBY_EXTERN VALUE cRubyPyInstance;

VALUE rpObjectWrap(PyObject* pObj)
{
	VALUE rObj;
	
	if(PyFunction_Check(pObj)||PyMethod_Check(pObj)||!PyObject_HasAttrString(pObj,"__dict__"))
	{
		return rpFunctionFromPyObject(pObj);

	}
	
	if(PyInstance_Check(pObj))
	{
		rObj = rpInstanceFromPyObject(pObj);
		return rObj;
	}
	
	return rpClassFromPyObject(pObj);
}


//Pass this function the argument list for a function call. Checks to see
//if the first parameter (the method symbol name here because this is called
//from within method_missing) ends with an equals
int rpSymbolIsSetter(VALUE args)
{
	VALUE mname;
	VALUE name_string;
	VALUE isSetter_;
	
	mname = rb_ary_entry(args, 0);
	name_string = rb_funcall(mname, rb_intern("to_s"), 0);
	
	isSetter_ = rb_funcall(name_string, rb_intern("end_with?"), 1, rb_str_new2("="));
	
	return Qtrue == isSetter_;
}



//Tests if the first argument ends with !!. See the comment for
//rpSymbolIsSetter
int rpSymbolIsDoubleBang(VALUE args)
{
	VALUE mname = rb_ary_entry(args, 0);
	VALUE name_string = rb_funcall(mname, rb_intern("to_s"), 0);
	
	return Qtrue == rb_funcall(name_string, rb_intern("end_with?"), 1, rb_str_new2("!!"));
}
