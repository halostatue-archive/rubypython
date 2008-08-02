#include "cbridge.h"

#define SAFE_START(reg) do { \
	reg=0; \
	if(!Py_IsInitialized())\
	{\
		Py_Initialize();\
		reg=1;\
	}\
} while(0)

#define SAFE_END(reg) do {\
	if(reg && Py_IsInitialized()) \
	{\
		Py_Finalize(); \
	} \
	} while(0)
	
int safe_start()
{
	int here;
	SAFE_START(here);
	return here;
}

void safe_stop(int here)
{
	SAFE_END(here);
}



VALUE rp_call_func_with_module_name(VALUE module,VALUE name,VALUE args)
{
	char* func_name=STR2CSTR(name);
	VALUE rArgs;
	VALUE rReturn;
	if(!(TYPE(args)==T_ARRAY))
	{
		rArgs=rb_ary_new();
		rb_ary_push(rArgs,args);
	}
	else
	{
		rArgs=args;
	}
	
	PyObject *pModuleName,*pModule,*pFunc,*pArgs,*pReturn;
	if(rb_eql(module,rb_str_new2("builtins")))
	{
		module=rb_str_new2("__builtins__");
	}
	pModuleName=rtop_obj(module,0);
	pModule=PyImport_Import(pModuleName);
	Py_XDECREF(pModuleName);
	if(PyErr_Occurred())
	{
		rp_pythonerror();
		return Qnil;
	}
	
	
	pFunc=PyObject_GetAttrString(pModule,func_name);
	
	pArgs=rtop_obj(rArgs,1);
	
	pReturn=PyObject_CallObject(pFunc,pArgs);
	
	if(PyErr_Occurred())
	{
		Py_XDECREF(pReturn);
		Py_XDECREF(pArgs);
		Py_XDECREF(pFunc);
		Py_XDECREF(pModule);
		rp_pythonerror();
		return Qnil;
	}
	
	rReturn=ptor_obj(pReturn);
	
	Py_XDECREF(pArgs);
	Py_XDECREF(pFunc);
	Py_XDECREF(pModule);
	return rReturn;
}

PyObject* rp_get_module(VALUE mname)
{
	if(rb_eql(mname,rb_str_new2("builtins")))
	{
		mname=rb_str_new2("__builtins__");
	}
	printf("here\n");
	PyObject *pModule,*pModuleName;
	pModuleName=rtop_string(mname);
	pModule=PyImport_Import(pModuleName);
	Py_XDECREF(pModuleName);
	if(PyErr_Occurred())
	{
		Py_XDECREF(pModule);
		rp_pythonerror();
		return Py_None;
	}
	return pModule;
}

PyObject* rp_get_func_with_module(PyObject* pModule,VALUE name)
{
	PyObject *pFunc;
	pFunc=PyObject_GetAttrString(pModule,STR2CSTR(name));
	if(PyErr_Occurred())
	{
		Py_XDECREF(pFunc);
		rp_pythonerror();
		return Py_None;
	}
	return pFunc;
}

VALUE rp_call_func(PyObject* pFunc, VALUE args)
{
	VALUE rArgs,rReturn;
	PyObject *pReturn,*pArgs;
	if(!(TYPE(args)==T_ARRAY))
	{
		rArgs=rb_ary_new();
		rb_ary_push(rArgs,args);
	}
	else
	{
		rArgs=args;
	}
	pArgs=rtop_obj(rArgs,1);
	pReturn=PyObject_CallObject(pFunc,pArgs);
	
	if(PyErr_Occurred())
	{
		Py_XDECREF(pArgs);
		Py_XDECREF(pReturn);
		rp_pythonerror();
		return Qnil;
	}
	rReturn=ptor_obj(pReturn);
	
	Py_XDECREF(pArgs);
	Py_XDECREF(pReturn);
	
	return rReturn;
}

