#include "rubypython_bridge.h"

#include "ptor.h" //PyObject* to VALUE conversion
#include "rtop.h" //VALUE to PyObject* conversion
#include "cbridge.h" //General interface functions
#include "rp_error.h" //Error propogation from Python to Ruby
#include "rp_object.h"
#include "rp_blankobject.h"
#include "rp_util.h"
#include "rp_module.h"
#include "rp_class.h"
#include "rp_function.h"

VALUE mRubyPythonBridge;

RUBY_EXTERN VALUE cRubyPyObject;
RUBY_EXTERN VALUE cRubyPyModule;
RUBY_EXTERN VALUE cRubyPyClass;
RUBY_EXTERN VALUE cBlankObject;


/*
call - seq: func(modname, funcname, *args)

Given a python module name _modname_ and a function name _funcname_ calls the given function
with the supplied arguments.

Use builtins as the module for a built in function.

*/
static VALUE func_with_module(VALUE self, VALUE args)
{
	// Before doing anything we attempt to start the interpreter
	// Started here will be 1 if the interpreter is started by this
	// function and zero otherwise
	int started_here = rpSafeStart();
	
	VALUE module, func, return_val;
	
	// If we hav less than two arguments we cannot proceed.
	// Perhaps it would make more sense to throw an error here.
	if(RARRAY_LEN(args) < 2) return Qfalse;
	
	module = rb_ary_shift(args);
	func = rb_ary_shift(args);
	
	// rpCallWithModule is defined in cbridge.c
	return_val = rpCallWithModule(module, func, args);

	// If we started the interpreter, we now halt it.
	rpSafeStop(started_here);
	
	return return_val;
}


/*
* call - seq: import(modname)
* 
* Imports the python module _modname_ using the interpreter and returns a ruby wrapper
*/
static VALUE rp_import(VALUE self, VALUE mname)
{
	return rb_class_new_instance(1,&mname, cRubyPyModule);
}


/*
* call - seq: start()
*
* Starts the python interpreter
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

/*
* call - seq: stop()
*
* Stop the python interpreter
*/
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
* Module containing an interface to the the python interpreter.
*
* Use RubyPython instead.
*/
void Init_rubypython_bridge()
{
	mRubyPythonBridge = rb_define_module("RubyPythonBridge");
	rb_define_module_function(mRubyPythonBridge,"func", func_with_module,- 2);
	rb_define_module_function(mRubyPythonBridge,"start", rp_start, 0);
	rb_define_module_function(mRubyPythonBridge,"stop", rp_stop, 0);
	rb_define_module_function(mRubyPythonBridge,"import", rp_import, 1);
	Init_BlankObject();
	Init_RubyPyObject();
	Init_RubyPyModule();
	Init_RubyPyClass();
	Init_RubyPyFunction();
	Init_RubyPyError();
	Init_RubyPyInstance();
	
}
