#include "cbridge.h"


int safe_start()
{
	int here;
	
	if(!Py_IsInitialized())
	{
		Py_Initialize();
		here = 1;
	}
	
	return here;
}


void safe_stop(int here)
{
	if(here && Py_IsInitialized())
	{
		Py_Finalize();
	}
}



VALUE rp_call_func_with_module_name(VALUE module,VALUE name,VALUE args)
{

	VALUE rArgs;
	VALUE rReturn;

	PyObject *pModuleName,*pModule,*pFunc,*pArgs,*pReturn;

	char* functionName;

	functionName = STR2CSTR(name);

/* 	Check to see if the passed argument is an array. If it is we
 * 	box it in another array so that the presentation of
 * 	arguments is the same i.e. each method is supllied with an
 * 	array of arguments.
 */
	if(!(TYPE(args)==T_ARRAY))
	{
		rArgs=rb_ary_new();
		rb_ary_push(rArgs,args);
	}
	else
	{
		rArgs=args;
	}
	
	//A little syntatic sugar here. We will allow users access the
	//__builtins__ module under the name builtins
	//FIXME: replace this with a call to rb_get_module

	if(rb_eql(module,rb_str_new2("builtins")))
	{
		module=rb_str_new2("__builtins__");
	}

	//Load the Python module into the pModule variable
	pModuleName=rtop_obj(module,0);
	pModule=PyImport_Import(pModuleName);
	Py_XDECREF(pModuleName);

	//Check for Errors and propagate them if they have occurred.
	if(PyErr_Occurred())
	{
		rp_pythonerror();
		return Qnil;
	}
	
	
	//Get a pointer to the request function
	pFunc=PyObject_GetAttrString(pModule,functionName);
	
	//Convert the supplied arguments to python objects
	pArgs=rtop_obj(rArgs,1);
	
	//Execute the function and obtain a pointer to the return object
	pReturn=PyObject_CallObject(pFunc,pArgs);
	
	//Check for an error and do any necessary cleanup before
	//propagating error
	if(PyErr_Occurred())
	{
		//FIXME: can some of this redundancy be removed?
		Py_XDECREF(pReturn);
		Py_XDECREF(pArgs);
		Py_XDECREF(pFunc);
		Py_XDECREF(pModule);
		rp_pythonerror();
		return Qnil;
	}
	
	//Convert return value to ruby object, do cleanup of python
	//objects and return.
	rReturn=ptor_obj(pReturn);
	
	Py_XDECREF(pArgs);
	Py_XDECREF(pFunc);
	Py_XDECREF(pModule);

	return rReturn;
}

PyObject* rp_get_module(VALUE mname)
{
	PyObject *pModule,*pModuleName;

	if(rb_eql(mname,rb_str_new2("builtins")))
	{
		mname=rb_str_new2("__builtins__");
	}

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

	rReturn=ptor_obj_no_destruct(pReturn);	
	Py_XDECREF(pArgs);

	return rReturn;
}
