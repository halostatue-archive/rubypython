#include "bridge.h"

VALUE mRubyPython;
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
	safe_end(started_here);
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
Document-Class: RubyPython
Wrapper for python interpreter

*/


/*
* Document-Method: start
* call-seg: start()
*
* Starts the python interpreter
* 	RubyPython.start
*/
VALUE python_start(VALUE self)
{
	int here;
	SAFE_START(here);
	if(here) return Qtrue;
	return Qfalse;
}

VALUE python_stop(VALUE self)
{
	return Qnil;
}

/*
* The top level module for Ruby Python bridge functions.
*
*/
void Init_RubyPython()
{
	mRubyPython=rb_define_module("RubyPython");
	rb_define_module_function(mRubyPython,"func_with_module",func_with_module,-2);
	rb_define_module_function(mRubyPython,"import_module",rp_import_module,1); 
	rb_define_module_function(mRubyPython,"start",python_start,0); // in: bridge.c
	rb_define_module_function(mRubyPython,"stop",python_stop,0);  // in: bridge.c
	rb_define_module_function(mRubyPython,"run",rp_python_block,0);
	
	rb_define_module_function(mRubyPython,"import",rp_import,1);
}
void Init_bridge()
{	
	Init_RubyPtyhon();
	Init_RubyPyObject();
	Init_RubyPyModule();
	Init_RubyPyClass();
}