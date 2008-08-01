#include "rbpy_object.h"

extern VALUE mRubyPython; // in: rbpython.c

VALUE cRubyPyObject;
VALUE cRubyPyModule;
VALUE cRubyPyClass;

void rbpyobj_mark(PObj* self)
{}

void rbpyobj_free(PObj* self)
{
	if(Py_IsInitialized())
	{
		Py_XDECREF(self->pObject);
	}
}

VALUE rbpyobj_alloc(VALUE klass)
{
	PObj* self=ALLOC(PObj);
	self->pObject=NULL;
	return Data_Wrap_Struct(klass,rbpyobj_mark,rbpyobj_free,self);
}

VALUE pymod_init(VALUE self,VALUE mname)
{
	PObj* cself;
	Data_Get_Struct(self,PObj,cself);
	cself->pObject=rp_get_module(mname);
	VALUE pClasses;
	pClasses=pymod_getclasses(cself->pObject);
	rb_iv_set(self,"@pclasses",pClasses);
	return self;
}

VALUE pymod_getclasses(PyObject *pModule)
{
	Py_ssize_t pos=0;
	PyObject *pModuleDict,*pModuleValues,*pKey,*pVal;
	VALUE rClassHash;
	rClassHash=rb_hash_new();
	pModuleDict=PyModule_GetDict(pModule);
	while(PyDict_Next(pModule,&pos,&pKey,&pVal))
	{
		if(PyType_Check(pVal))
		{
			Py_XINCREF(pVal);
			rb_hash_aset(rClassHash,ptor_string(pKey),pycla_from_class(pVal));
		}
	}
	return rClassHash;
}

VALUE pymod_classdelegate(VALUE self, VALUE klass)
{
	VALUE rClasses=rb_iv_get(self,"@pclasses");
	if(FALSE_P(funccal(rClasses,rb_intern("member?"),1,klass)))
	{
		return super(1,&klass);
	}
	VALUE rClass=rb_hash_aref(rClasses,klass);
	return rClass;
}

VALUE pycla_from_class(PyObject *pClass)
{
	PObj* self;
	VALUE rClass=rb_class_new_instance(0,NULL,cRubyPyClass);
	Data_Get_Struct(rClass,PObj,self);
	self->pObject=pClass;
	return rClass;
}

VALUE rp_pymod_call_func(VALUE self,VALUE func_name,VALUE args)
{
	PObj *cself;
	Data_Get_Struct(self,PObj,cself);
	PyObject *pModule,*pFunc;
	VALUE rReturn;
	
	pModule=cself->pObject;
	pFunc=rp_get_func_with_module(pModule,func_name);
	rReturn=rp_call_func(pFunc,args);
	Py_XDECREF(pFunc);
	
	return rReturn;
	
}

int pymod_has_func(VALUE self,VALUE func_name)
{
	PObj *cself;
	VALUE rName;
	Data_Get_Struct(self,PObj,cself);
	rName=rb_funcall(func_name,rb_intern("to_s"),0);
	
	if(PyObject_HasAttrString(cself->pObject,STR2CSTR(rName))) return 1;
	return 0;
}

VALUE pymod_delegate(VALUE self,VALUE args)
{
	VALUE mname,name_string;
	PObj* cself;
	
	if(!pymod_has_func(self,rb_ary_entry(args,0)))
	{
		
		int i=0;
		VALUE *rSuperArgs,*Arg;
		int num_args;
		num_args=RARRAY(args)->len;
		rSuperArgs=ALLOC_N(VALUE,num_args);
		Arg=rSuperArgs;
		for(i=0;i<num_args;i++)
		{
			*Arg=rb_ary_entry(args,i);
			Arg=Arg+sizeof(VALUE);
		}
		return rb_call_super(num_args,rSuperArgs);
	}
	mname=rb_ary_shift(args);
	
	name_string=rb_funcall(mname,rb_intern("to_s"),0);
	
	return rp_pymod_call_func(self,name_string,args);
}

void Init_RubyPyObject()
{
	cRubyPyObject=rb_define_class_under(mRubyPython,"RubyPyObject",rb_cObject);
	rb_define_alloc_func(cRubyPyObject,rbpyobj_alloc);
	
}

void Init_RubyPyModule()
{
	cRubyPyModule=rb_define_class_under(mRubyPython,"RubyPyModule",cRubyPyObject);
	rb_define_method(cRubyPyModule,"initialize",pymod_init,1);
	rb_define_method(cRubyPyModule,"method_missing",pymod_delegate,-2);
	rb_define_method(cRubyPyModule,"const_missing",pymod_classdelegate,1);	
}

void Init_RubyPyClass()
{
	cRubyPyClass=rb_define_class_under(mRubyPython,"RubyPyClass",cRubyPyObject);
}