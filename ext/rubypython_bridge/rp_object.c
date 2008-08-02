#include "rp_object.h"
#include "stdio.h"

extern VALUE mRubyPythonBridge;

VALUE cRubyPyObject;
VALUE cRubyPyModule;
VALUE cRubyPyClass;
VALUE cRubyPyFunction;

void rp_obj_mark(PObj* self)
{}

void rp_obj_free(PObj* self)
{
	if(Py_IsInitialized())
	{
		Py_XDECREF(self->pObject);
	}
	free(self);
}

VALUE rp_obj_free_pobj(VALUE self)
{
	PObj *cself;
	Data_Get_Struct(self,PObj,cself);
	if(Py_IsInitialized())
	{
		Py_XDECREF(cself->pObject);
		cself->pObject=NULL;
		return Qtrue;
	}
	return Qfalse;
}

VALUE rp_obj_alloc(VALUE klass)
{
	PObj* self=ALLOC(PObj);
	self->pObject=NULL;
	return Data_Wrap_Struct(klass,rp_obj_mark,rp_obj_free,self);
}

VALUE rp_mod_init(VALUE self,VALUE mname)
{
	PObj* cself;
	Data_Get_Struct(self,PObj,cself);
	cself->pObject=rp_get_module(mname);
	return self;
}

PyObject* rp_obj_pobject(VALUE self)
{
	PObj *cself;
	Data_Get_Struct(self,PObj,cself);
	return cself->pObject;
}

VALUE rp_obj_name(VALUE self)
{
	if(Py_IsInitialized())
	{
	PyObject *pObject;
	pObject=rp_obj_pobject(self);
	return ptor_obj(PyObject_GetAttrString(pObject,"__name__"));		
	}
	return rb_string_new2("__FREED__");

}

VALUE rp_obj_from_pyobject(PyObject *pObj)
{
	PObj* self;
	VALUE rObj=rb_class_new_instance(0,NULL,cRubyPyObject);
	Data_Get_Struct(rObj,PObj,self);
	self->pObject=pObj;
	return rObj;
}

VALUE rp_mod_getclasses(PyObject *pModule)
{
	Py_ssize_t pos=0;
	PyObject *pModuleDict,*pModuleValues,*pKey,*pVal;
	VALUE rClassHash;
	rClassHash=rb_hash_new();
	pModuleDict=PyModule_GetDict(pModule);
	while(PyDict_Next(pModule,&pos,&pKey,&pVal))
	{
		printf("Hello?\n");
		if(PyType_Check(pVal))
		{
			Py_XINCREF(pVal);
			rb_hash_aset(rClassHash,ptor_string(pKey),rp_cla_from_class(pVal));
		}
	}
	return rClassHash;
}

VALUE rp_mod_classdelegate(VALUE self, VALUE klass)
{
	VALUE rClasses=rb_iv_get(self,"@pclasses");
	VALUE rClass=rb_hash_aref(rClasses,klass);
	return rClass;
}

VALUE rp_cla_from_class(PyObject *pClass)
{
	PObj* self;
	VALUE rClass=rb_class_new_instance(0,NULL,cRubyPyClass);
	Data_Get_Struct(rClass,PObj,self);
	self->pObject=pClass;
	return rClass;
}

VALUE rp_func_from_function(PyObject *pFunc)
{
	PObj* self;
	VALUE rFunc=rb_class_new_instance(0,NULL,cRubyPyFunction);
	Data_Get_Struct(rFunc,PObj,self);
	self->pObject=pFunc;
	return rFunc;
}

VALUE rp_mod_call_func(VALUE self,VALUE func_name,VALUE args)
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

int rp_has_attr(VALUE self,VALUE func_name)
{
	
	PObj *cself;
	VALUE rName;
	Data_Get_Struct(self,PObj,cself);
	rName=rb_funcall(func_name,rb_intern("to_s"),0);
	if(PyObject_HasAttrString(cself->pObject,STR2CSTR(rName))) return 1;
	return 0;
}

VALUE rp_mod_delegate(VALUE self,VALUE args)
{
	VALUE name,name_string,rClasses;
	PObj* cself;
	
	if(!rp_has_attr(self,rb_ary_entry(args,0)))
	{
		
		int argc;
		argc=RARRAY(args)->len;
		VALUE *argv;
		argv=ALLOC_N(VALUE,argc);
		MEMCPY(argv,RARRAY(args)->ptr,VALUE,argc);
		return rb_call_super(argc,argv);
	}
	
	name=rb_ary_shift(args);
	name_string=rb_funcall(name,rb_intern("to_s"),0);
	
	// rClasses=rb_iv_get(self,"@pclasses");
	// if(rb_funcall(rClasses,rb_intern("member?"),1,name))
	// {
	// 	return rp_mod_classdelegate(self,name_string);
	// }	
	
	return rp_mod_call_func(self,name_string,args);
}

VALUE rp_newmod_init(VALUE self, VALUE mname)
{
	PObj* cself;
	Data_Get_Struct(self,PObj,cself);
	cself->pObject=rp_get_module(mname);
	VALUE rDict;
	PyObject *pModuleDict;
	pModuleDict=PyModule_GetDict(cself->pObject);
	Py_XINCREF(pModuleDict);
	rDict=rp_cla_from_class(pModuleDict);
	rb_iv_set(self,"@pdict",rDict);
	return self;
}

int rp_is_func(VALUE pObj)
{
	PObj* self;
	Data_Get_Struct(pObj,PObj,self);
	Py_XINCREF(self->pObject);
	return (PyFunction_Check(self->pObject)||PyMethod_Check(self->pObject));
}
VALUE rp_newmod_delegate(VALUE self,VALUE args)
{
	VALUE name,name_string,rDict,result;
	PObj *pDict;
	PyObject *pCalled;
	if(!rp_has_attr(self,rb_ary_entry(args,0)))
	{		
		int argc;
		
		VALUE *argv;
		argc=RARRAY(args)->len;
		argv=ALLOC_N(VALUE,argc);
		MEMCPY(argv,RARRAY(args)->ptr,VALUE,argc);
		return rb_call_super(argc,argv);
	}
	name=rb_ary_shift(args);
	name_string=rb_funcall(name,rb_intern("to_s"),0);
	
	rDict=rb_iv_get(self,"@pdict");
	Data_Get_Struct(rDict,PObj,pDict);
	pCalled=PyDict_GetItemString(pDict->pObject,STR2CSTR(name_string));
	result=ptor_obj_no_destruct(pCalled);
	if(rb_obj_is_instance_of(result,cRubyPyFunction))
	{
		return rp_call_func(pCalled,args);
	}
	return result;
	
}

// A wrapper around generic Python object, allowing them to passed around in ruby
inline void Init_RubyPyObject()
{
	cRubyPyObject=rb_define_class_under(mRubyPythonBridge,"RubyPyObject",rb_cObject);
	rb_define_alloc_func(cRubyPyObject,rp_obj_alloc);
	rb_define_method(cRubyPyObject,"free_pobj",rp_obj_free_pobj,0);
	rb_define_method(cRubyPyObject,"__name",rp_obj_name,0);
	
}

// A wrapper for Python Modules to allow importing from within ruby
inline void Init_RubyPyModule()
{
	cRubyPyModule=rb_define_class_under(mRubyPythonBridge,"RubyPyModule",cRubyPyObject);
	rb_define_method(cRubyPyModule,"initialize",rp_newmod_init,1);
	rb_define_method(cRubyPyModule,"method_missing",rp_newmod_delegate,-2);
	rb_define_method(cRubyPyModule,"const_missing",rp_mod_classdelegate,1);	
}

// :nodoc:
inline void Init_RubyPyClass()
{
	cRubyPyClass=rb_define_class_under(mRubyPythonBridge,"RubyPyClass",cRubyPyObject);
}

void Init_RubyPyFunction()
{
	cRubyPyFunction=rb_define_class_under(mRubyPythonBridge,"RubyPyFunction",cRubyPyObject);
}