#include "rubypython_bridge.h"

VALUE mRubyPythonBridge;
extern VALUE cRubyPyObject;
extern VALUE cRubyPyModule;
extern VALUE cRubyPyClass;

static VALUE func_with_module(VALUE self, VALUE args)
{
	int started_here=safe_start();
	VALUE module,func,return_val;
	if(RARRAY(args)->len<2) return Qfalse;
	module=rb_ary_shift(args);
	func=rb_ary_shift(args);
	return_val=rp_call_func_with_module_name(module,func,args);
	safe_stop(started_here);
	return return_val;
}

static VALUE rp_import_module(VALUE self,VALUE module)
{
	VALUE instance=rb_class_instance_new(1,&module,cRubyPyModule);
	return instance;
}



/*
* call-seq: import(modname)
* 
* imports a python file_module using the interpreter and returns ruby wrapper

*/
static VALUE rp_import(VALUE self,VALUE mname)
{
	return rb_class_new_instance(1,&mname,cRubyPyModule);
}

static VALUE rp_python_block(VALUE self)
{
	rb_funcall(self,rb_intern("start"),0);
	rb_obj_instance_eval(0,NULL,self);
	rb_funcall(self,rb_intern("stop"),0);
	
}



/*
* call-seq: start()
*
* Starts the python interpreter
* 	RubyPython.start
*/
VALUE rp_start(VALUE self)
{
	if(Py_IsInitialized())
	{
		return Qfalse;
	}
	Py_Initialize();
	return Qtrue;
}

VALUE rp_stop(VALUE self)
{
	
	if(Py_IsInitialized())
	{
		Py_Finalize();
		return Qtrue;
	}
	return Qfalse;
	
}

/*
* Document-Module: RubyPythonBridge
* Module containing an interface to the the python interpreter.
*
*/

void Init_rubypython_bridge()
{
	mRubyPythonBridge=rb_define_module("RubyPythonBridge");
	rb_define_module_function(mRubyPythonBridge,"func_with_module",func_with_module,-2);
	rb_define_module_function(mRubyPythonBridge,"import_module",rp_import_module,1); 
	rb_define_module_function(mRubyPythonBridge,"start",rp_start,0);
	rb_define_module_function(mRubyPythonBridge,"stop",rp_stop,0);
	rb_define_module_function(mRubyPythonBridge,"run",rp_python_block,0);
	rb_define_module_function(mRubyPythonBridge,"import",rp_import,1);
	Init_RubyPyObject();
	Init_RubyPyModule();
	Init_RubyPyClass();
	Init_RubyPyFunction();
}