#include "py_object.h"

#include "ptor.h"
#include "rtop.h"

RUBY_EXTERN VALUE mRubyPyApi;

VALUE cRubyPyObject;
VALUE nilVal = (VALUE) 4;

static VALUE PyStructAlloc(VALUE);
static void PyStructFree(PyStruct*);


//Create a new PyStruct
static
VALUE PyStructAlloc(VALUE klass)
{
	PyStruct* self = ALLOC(PyStruct);
	self->pObject = NULL;
	
	return Data_Wrap_Struct(klass, 0, PyStructFree, self);
}


//Delete a PyStruct
static
void PyStructFree(PyStruct* self)
{
	if(Py_IsInitialized() && self->pObject)
	{
		//Make sure we decrement the object count on our wrapped
		//object before we free the ruby wrapper
		Py_XDECREF(self->pObject);
	}
	free(self);
}

static
VALUE rpRubify(VALUE self) {
    VALUE rbObject;
    PyObject* pObject;
    PyStruct* pyStruct;
    
    Data_Get_Struct(self, PyStruct, pyStruct);
    
    pObject = pyStruct->pObject;
    
    rbObject = ptorObject(pObject);
    
    return rbObject;
}

static
VALUE PyStructInit(VALUE self, VALUE rbObject) {
	PyObject* pObject;
	PyStruct* cSelf;
	
	pObject = rtopObject(rbObject, 0);
	
	Data_Get_Struct(self, PyStruct, cSelf);
	
	Py_XDECREF(cSelf->pObject);
	cSelf->pObject = pObject;

	return self;
}

static
VALUE rpHasAttr(VALUE self, VALUE attrName) {
	PyStruct* cSelf;
	char* cName;
	VALUE has;
	
	cName = STR2CSTR(attrName);
	
	Data_Get_Struct(self, PyStruct, cSelf);
	
	if(PyObject_HasAttrString(cSelf->pObject, cName)) {
		has = Qtrue;
	} else {
		has = Qfalse;
	}
	
	return has;
	
}

static
VALUE rpGetAttr(VALUE self, VALUE attrName) {
	PyStruct* cSelf;
	PyStruct* cAttr;
	PyObject* pyAttr;
	char* cName;
	VALUE rbAttr;
	
	cName = STR2CSTR(attrName);
	
	Data_Get_Struct(self, PyStruct, cSelf);
	
	pyAttr = PyObject_GetAttrString(cSelf->pObject, cName);
	
	rbAttr = rb_class_new_instance(1, &nilVal, cRubyPyObject);
	
	Data_Get_Struct(rbAttr, PyStruct, cAttr);
	
	Py_XDECREF(cAttr->pObject);
	
	cAttr->pObject = pyAttr;
	
	return rbAttr;
	
}

static
VALUE rpSetAttr(VALUE self, VALUE attrName, VALUE rbPyAttr) {
	PyStruct* cSelf;
	PyStruct* cAttr;
	char* cName;
	
	cName = STR2CSTR(attrName);
	
	Data_Get_Struct(self, PyStruct, cSelf);
	Data_Get_Struct(rbPyAttr, PyStruct, cAttr);
	
	PyObject_SettAttrString(cSelf->pObject, cName, cAttr->pObject);
	
	return Qtrue;
}

static
VALUE rpCallObject(VALUE self, VALUE rbCallable, VALUE args) {
	PyStruct* cSelf;
	PyStruct* cReturn;
	PyObject* argTuple;
	PyObject* pyReturn;
	VALUE rbReturn;
	
	argTuple = rtopObject(args, 1);
	
	Data_Get_Struct(self, PyStruct, cSelf);
	
	pyReturn = PyObject_CallObject(cSelf->pObject, argTuple);
	
	rbReturn = rb_class_new_instance(1, &nilVal, cRubyPyObject);
	
	Data_Get_Struct(rbReturn, PyStruct, cReturn);
	
	Py_XDECREF(cReturn->pObject);
	
	cReturn->pObject = pyReturn;
	
	return rbReturn;

}

static
VALUE rpXDECREF(VALUE self) {
	PyStruct* cSelf;

	Data_Get_Struct(self, PyStruct, cSelf);
	
	Py_XDECREF(cSelf->pObject);
	
	cSelf->pObject = NULL;
	
	return self;
}

static
VALUE rpXINCREF(VALUE self) {
	PyStruct* cSelf;

	Data_Get_Struct(self, PyStruct, cSelf);
	
	Py_XINCREF(cSelf->pObject);
	
	return self;
}

inline void Init_RubyPyObject() {
	cRubyPyObject = rb_define_class_under(mRubyPyApi,"PyObject", rb_cObject);
        rb_define_alloc_func(cRubyPyObject, PyStructAlloc);
	rb_define_method(cRubyPyObject, "initialize", &PyStructInit, 1);
        rb_define_method(cRubyPyObject, "rubify", &rpRubify, 0);
	rb_define_method(cRubyPyObject, "hasAttr", &rpHasAttr, 1);
	rb_define_method(cRubyPyObject, "getAttr", &rpGetAttr, 1);
	rb_define_method(cRubyPyObject, "setAttr", &rpSetAttr, 2);
	rb_define_method(cRubyPyObject, "callObject", &rpCallObject, 2);
	rb_define_method(cRubyPyObject, "xDecref", &rpXDECREF, 0);
	rb_define_method(cRubyPyObject, "xIncref", &rpXINCREF, 0);
}