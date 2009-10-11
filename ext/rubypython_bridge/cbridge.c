#include "cbridge.h"

#import "rtop.h"

/* Attempt to initialize the embedded python interpreter.
  Return 1 if we initialize it here and 0 if the interpreter is
  already running.
*/
int rpSafeStart()
{
	int here;
	
	if(!Py_IsInitialized())
	{
		Py_Initialize();
		here = 1;
	}
	
	return here;
}

/* Attempt to stop the embedded python interpreter.*/
void rpSafeStop(int here)
{
	
	if(here && Py_IsInitialized())
	{
		Py_Finalize();
	}
}

VALUE rpCall(PyObject* pFunc,  VALUE args)
{
	VALUE rArgs, rReturn;
	PyObject *pReturn, *pArgs;

/* 	Check to see if the passed argument is an array. If it is we
 * 	box it in another array so that the presentation of
 * 	arguments is the same i.e. each method is supllied with an
 * 	array of arguments.
 */
	if(!(TYPE(args) == T_ARRAY))
	{
		
		rArgs = rb_ary_new();
		rb_ary_push(rArgs, args);
	}
	else
	{
		rArgs = args;
	}

	pArgs = rtopObject(rArgs, 1);
	pReturn = PyObject_CallObject(pFunc, pArgs);
	
	if(PyErr_Occurred())
	{
		Py_XDECREF(pArgs);
		Py_XDECREF(pReturn);
		rpPythonError();
		return Qnil;
	}

	rReturn = ptorObjectKeep(pReturn);	
	Py_XDECREF(pArgs);

	return rReturn;
}

VALUE rpCallWithModule(VALUE module, VALUE name, VALUE args)
{

	VALUE rArgs;
	VALUE rReturn;

	PyObject *pModule, *pFunc, *pArgs, *pReturn;


	if(!(TYPE(args) == T_ARRAY))
	{
		rArgs = rb_ary_new();
		rb_ary_push(rArgs, args);
	}
	else
	{
		rArgs = args;
	}
	
	// A little syntatic sugar here. We will allow users access the
	// __builtins__ module under the name builtins
	// FIXME: replace this with a call to rb_get_module

	if(rb_eql(module, rb_str_new2("builtins")))
	{
		module = rb_str_new2("__builtins__");
	}

	// Load the requested python module
	pModule = rpGetModule(module);
	
	// Get a pointer to the requested function
	pFunc = rpGetFunctionWithModule(pModule, name);
	
	// Convert the supplied arguments to python objects
	pArgs = rtopObject(rArgs, 1);
	
	// Execute the function and obtain a pointer to the return object
	pReturn = PyObject_CallObject(pFunc, pArgs);
	
	// Check for an error and do any necessary cleanup before
	// propagating error
	if(PyErr_Occurred())
	{
		// FIXME: can some of this redundancy be removed?
		Py_XDECREF(pReturn);
		Py_XDECREF(pArgs);
		Py_XDECREF(pFunc);
		Py_XDECREF(pModule);
		rpPythonError();
		return Qnil;
	}
	
	// Convert return value to ruby object,  do cleanup of python
	// objects and return.
	rReturn = ptorObject(pReturn);
	
	Py_XDECREF(pArgs);
	Py_XDECREF(pFunc);
	Py_XDECREF(pModule);

	return rReturn;
}

PyObject* rpGetModule(VALUE mname)
{
	PyObject *pModule, *pModuleName;

	if(rb_eql(mname, rb_str_new2("builtins")))
	{
		mname = rb_str_new2("__builtins__");
	}

	pModuleName = rtopString(mname);
	pModule = PyImport_Import(pModuleName);
	Py_XDECREF(pModuleName);

	if(PyErr_Occurred())
	{
		Py_XDECREF(pModule);
		rpPythonError();
		return Py_None;
	}

	return pModule;
}

PyObject* rpGetFunctionWithModule(PyObject* pModule, VALUE name)
{
	PyObject *pFunc;

	pFunc = PyObject_GetAttrString(pModule, STR2CSTR(name));

	if(PyErr_Occurred())
	{
		Py_XDECREF(pFunc);
		rpPythonError();
		return Py_None;
	}

	return pFunc;
}


