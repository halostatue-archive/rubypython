#include "rp_blankobject.h"

RUBY_EXTERN VALUE mRubyPythonBridge;

VALUE cBlankObject;

// :nodoc:
VALUE blank_undef_if(VALUE name, VALUE klass)
{
	VALUE mname = rb_funcall(name, rb_intern("to_s"), 0);
	if(rb_funcall(mname, rb_intern("match"), 1, rb_str_new2("(?:^__)|(?:\\?$)|(?:^send$)|(?:^class$)")) == Qnil)
	{
		rb_undef_method(klass, STR2CSTR(mname));
		return Qtrue;
	}
	else
	{
		return Qfalse;
	}
}

// :nodoc:
VALUE blank_obj_prep(VALUE self)
{
	VALUE instance_methods = rb_funcall(self, rb_intern("instance_methods"), 0);
	rb_iterate(rb_each, instance_methods, blank_undef_if, self);
	return self;
}

// :nodoc:
inline void Init_BlankObject()
{
	cBlankObject = rb_define_class_under(mRubyPythonBridge,"BlankObject", rb_cObject);
	blank_obj_prep(cBlankObject);
}