#include "py_object.h"

#include "ptor.h"
#include "rtop.h"

RUBY_EXTERN VALUE mRubyPyApi;

VALUE cRubyPyObject;

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
	
	//Py_XDECREF(cSelf->pObject);
	cSelf->pObject = pObject;

	return self;
}

static
VALUE rpHasAttr(VALUE self, VALUE attrName) {
	PyStruct* cSelf;
	char* cName;
	VALUE has;
	
	cName = StringValueCStr(attrName);
	
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
	
	cName = StringValueCStr(attrName);
	
	Data_Get_Struct(self, PyStruct, cSelf);
	
	pyAttr = PyObject_GetAttrString(cSelf->pObject, cName);
	
	rbAttr = rb_obj_alloc(cRubyPyObject);
	
	Data_Get_Struct(rbAttr, PyStruct, cAttr);
	
	cAttr->pObject = pyAttr;
	
	return rbAttr;
	
}

static
VALUE rpSetAttr(VALUE self, VALUE attrName, VALUE rbPyAttr) {
	PyStruct* cSelf;
	PyStruct* cAttr;
	char* cName;
	
	cName = StringValueCStr(attrName);
	
	Data_Get_Struct(self, PyStruct, cSelf);
	Data_Get_Struct(rbPyAttr, PyStruct, cAttr);
	
	PyObject_SetAttrString(cSelf->pObject, cName, cAttr->pObject);
	
	return Qtrue;
}

static
VALUE rpCallObject(VALUE self, VALUE rbPyArgs) {
	PyStruct* cSelf;
	PyStruct* cReturn;
	PyStruct* cArgs;
	PyObject* pyReturn;
	VALUE rbReturn;
	
	Data_Get_Struct(rbPyArgs, PyStruct, cArgs);
	
	Data_Get_Struct(self, PyStruct, cSelf);
	
	pyReturn = PyObject_CallObject(cSelf->pObject, cArgs->pObject);
	
	rbReturn = rb_obj_alloc(cRubyPyObject);
	
	Data_Get_Struct(rbReturn, PyStruct, cReturn);
	
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

static
VALUE rpIsNull(VALUE self) {
  PyStruct* cSelf;
  Data_Get_Struct(self, PyStruct, cSelf);

  if(cSelf->pObject)
    return Qfalse;
  else
    return Qtrue;
}

static
VALUE rpCompare(VALUE self, VALUE other) {
  PyStruct *cSelf, *cOther;
  VALUE rResult;
  int cResult;
  
  Data_Get_Struct(self, PyStruct, cSelf);
  Data_Get_Struct(other, PyStruct, cOther);

  cResult = PyObject_Compare(cSelf->pObject, cOther->pObject);

  rResult = INT2NUM(cResult);

  return rResult;
  
}

inline void Init_RubyPyObject() {
	cRubyPyObject = rb_define_class_under(mRubyPyApi,"PyObject", rb_cObject);
        rb_define_alloc_func(cRubyPyObject, PyStructAlloc);
	rb_define_method(cRubyPyObject, "initialize", &PyStructInit, 1);
        rb_define_method(cRubyPyObject, "rubify", &rpRubify, 0);
	rb_define_method(cRubyPyObject, "hasAttr", &rpHasAttr, 1);
	rb_define_method(cRubyPyObject, "getAttr", &rpGetAttr, 1);
	rb_define_method(cRubyPyObject, "setAttr", &rpSetAttr, 2);
	rb_define_method(cRubyPyObject, "callObject", &rpCallObject, 1);
	rb_define_method(cRubyPyObject, "xDecref", &rpXDECREF, 0);
	rb_define_method(cRubyPyObject, "xIncref", &rpXINCREF, 0);
	rb_define_method(cRubyPyObject, "null?", &rpIsNull, 0);
	rb_define_method(cRubyPyObject, "cmp", &rpCompare, 1);
}
