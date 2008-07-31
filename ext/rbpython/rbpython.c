#include "rbpython.h"

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



static VALUE rp_import(VALUE self,VALUE mname)
{
	return rb_class_new_instance(1,&mname,cRubyPyModule);
}

void Init_rbpython()
{
	mRubyPython=rb_define_module("RubyPython");
	rb_define_module_function(mRubyPython,"func_with_module",func_with_module,-2);
	rb_define_module_function(mRubyPython,"import_module",rp_import_module,1);
	rb_define_module_function(mRubyPython,"start",python_start,0);
	rb_define_module_function(mRubyPython,"stop",python_stop,0);
	rb_define_module_function(mRubyPython,"import",rp_import,1);
	
	Init_RubyPyObject();
}