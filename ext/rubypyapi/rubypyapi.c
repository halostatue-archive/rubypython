#include <ruby.h>
#include "py_macro.h"


VALUE mRubyPyApi;


/*
* Starts the python interpreter
*/
static
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
* Stop the python interpreter
*/
static
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
 * RubyPyApi module
 */
void 
Init_rubypyapi()
{
  mRubyPyApi = rb_define_module("RubyPyApi");
  //rb_define_module_function(mRubyPyApi, "start", rp_start, 0);
  //rb_define_module_function(mRubyPyApi, "stop", rp_stop, 0);

  Init_RubyPyObject();
  Init_RubyPyImport();
  Init_RubyPyError();
  //Init_RubyPyDict();
  Init_RubyPySys();
}
