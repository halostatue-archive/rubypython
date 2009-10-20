#include "rp_object.h"

RUBY_EXTERN VALUE ePythonError;
RUBY_EXTERN VALUE mRubyPythonBridge;
RUBY_EXTERN VALUE cBlankObject;

VALUE cRubyPyObject;


static void rpObjectMark(PObj*);
static void rpObjectFree(PObj*);
static VALUE rpObjectAlloc(VALUE);

//Create a new RubyPyObject
static
VALUE rpObjectAlloc(VALUE klass)
{
	PObj* self = ALLOC(PObj);
	self->pObject = NULL;
	
	return Data_Wrap_Struct(klass, rpObjectMark, rpObjectFree, self);
}

//Mark subsidiary objects for deletion
static
void rpObjectMark(PObj* self)
{}

//Delete a RubyPyObject
static
void rpObjectFree(PObj* self)
{
	if(Py_IsInitialized() && self->pObject)
	{
		//Make sure we decrement the object count on our wrapped
		//object before we free the ruby wrapper
		Py_XDECREF(self->pObject);
	}
	free(self);
}


/*
Decreases the reference count on the object wrapped by this instance.
This is used for cleanup in RubyPython.stop. RubyPyObject instances automatically
decrease the reference count on their associated objects before they are garbage collected.
*/
static
VALUE rpObjectFreePobj(VALUE self)
{
	PObj *cself;
	
	Data_Get_Struct(self, PObj, cself);
	
	if(Py_IsInitialized() && cself->pObject)
	{
		Py_XDECREF(cself->pObject);
		cself->pObject = NULL;
		return Qtrue;
	}
	else
	{
		cself->pObject = NULL;
	}
	
	return Qfalse;
}

//Fetchs the wrapped Python object from a RubyPyObject
PyObject* rpObjectGetPyObject(VALUE self)
{
	PObj *cself;
	
	Data_Get_Struct(self, PObj, cself);
	
	if(!cself->pObject)
	{
		rb_raise(ePythonError,"RubyPython tried to access a freed object");
	}
	
	return cself->pObject;
}


//Creates a new RubyPyObject to wrap a python object
VALUE rpObjectFromPyObject(PyObject* pObj)
{
	PObj* self;
	
	VALUE rObj = rb_class_new_instance(0, NULL, cRubyPyObject);
	
	Data_Get_Struct(rObj, PObj, self);
	
	self->pObject = pObj;
	
	return rObj;
}

/*
Returns the name of the Python object which this instance wraps.

If it cannot determine a reasonable name it just gives up.
*/
static
VALUE rpObjectectGetName(VALUE self)
{
	//It only makes sense to query a python object if the interpreter is running.
	if(Py_IsInitialized())
	{
		PyObject *pObject,*pName,*pRepr;
		VALUE rName;
		
		pObject = rpObjectGetPyObject(self);
		
		
		pName = PyObject_GetAttrString(pObject,"__name__");
		
		if(!pName)
		{
			PyErr_Clear();
			
			pName = PyObject_GetAttrString(pObject,"__class__");
	 		pRepr = PyObject_Repr(pName);
			rName = ptorString(pRepr);
			Py_XDECREF(pRepr);
			
			return rb_str_concat(rb_str_new2("An instance of "), rName);
			if(!pName)
			{
				PyErr_Clear();
				
				pName = PyObject_Repr(pObject);
				
				if(!pName)
				{
					PyErr_Clear();
					return rb_str_new2("__Unnameable__");
				}
			}
		}
		
		rName = ptorString(pName);
		
		Py_XDECREF(pName);
		
		return rName;
	}
	
	return rb_str_new2("__FREED__");

}

//Test to see the RubyPyObj has the supplied symbol as an attribute
int rpHasSymbol(VALUE self, VALUE symbol)
{
	PObj *cself;
	VALUE rName;
	
	Data_Get_Struct(self, PObj, cself);
	rName = rb_funcall(symbol, rb_intern("to_s"), 0);
	
	if(PyObject_HasAttrString(cself->pObject, STR2CSTR(rName))) return 1;
	
	return 0;
}

/* Tests whether the wrapped object will respond to the given method*/
VALUE rpRespondsTo(VALUE self, VALUE mname)
{
	if(rpHasSymbol(self, mname))
	{
		return Qtrue;
	}
	
	return Qfalse;
}

/*
A wrapper class for Python objects that allows them to manipulated from within ruby.

Important wrapper functionality is found in the RubyPyModule, RubyPyClass, and RubyPyFunction
classes which wrap Python objects of similar names.

*/
inline void Init_RubyPyObject()
{
	cRubyPyObject = rb_define_class_under(mRubyPythonBridge,"RubyPyObject", cBlankObject);
	rb_define_alloc_func(cRubyPyObject, rpObjectAlloc);
	rb_define_method(cRubyPyObject,"free_pobj", rpObjectFreePobj, 0);
	rb_define_method(cRubyPyObject,"__name", rpObjectectGetName, 0);
	rb_define_method(cRubyPyObject,"respond_to?", rpRespondsTo, 1);
	
}