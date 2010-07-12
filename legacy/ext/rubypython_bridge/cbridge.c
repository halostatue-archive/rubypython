#include "cbridge.h"

#include "rtop.h"
#include "ptor.h"
#include "rp_error.h"

/* Attempt to initialize the embedded python interpreter.
  Return 1 if we initialize it here and 0 if the interpreter is
  already running.
*/
int rpSafeStart()
{
	int here = 0;
	
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

	// Convert the supplied arguments to python objects
	pArgs = rtopObject(rArgs, 1);
	
	// Execute the function and obtain a pointer to the return object
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

	VALUE rReturn;

	PyObject *pModule, *pFunc;


	// Load the requested python module
	pModule = rpGetModule(module);
	
	// Get a pointer to the requested function
	pFunc = rpGetFunctionWithModule(pModule, name);
	
	Py_XDECREF(pModule);
	
	rReturn = rpCall(pFunc, args);
	
	// Check for an error and do any necessary cleanup before
	// propagating error
	if(PyErr_Occurred())
	{
		Py_XDECREF(pFunc);
		rpPythonError();
		return Qnil;
	}
	
	// Cleanup temporary objects
	Py_XDECREF(pFunc);

	return rReturn;
}

PyObject* rpGetModule(VALUE mname)
{
	PyObject *pModule, *pModuleName;

	// A little syntatic sugar here. We will allow users access the
	// __builtins__ module under the name builtins
	// FIXME: replace this with a call to rb_get_module
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


