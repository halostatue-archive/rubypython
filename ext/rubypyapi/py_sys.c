#include "py_sys.h"

#include "py_object.h"

RUBY_EXTERN VALUE mRubyPyApi;
RUBY_EXTERN VALUE cRubyPyObject;

static
VALUE rpGetObject(VALUE mod, VALUE rbName) {
  char* cName;

  PyStruct* cReturn;
  PyObject* pReturn;
  VALUE rReturn;

  cName = StringValueCStr(rbName);

  pReturn = PySys_GetObject(cName);

  rReturn = rb_obj_alloc(cRubyPyObject);

  Data_Get_Struct(rReturn, PyStruct, cReturn);

  cReturn->pObject = pReturn;

  return rReturn;
  
}

static
VALUE rpSetObject(VALUE mod, VALUE rbName, VALUE rbObject) {
  char* cName;

  PyStruct* cObject;

  VALUE rReturn;
  int cReturn;

  cName = StringValueCStr(rbName);

  Data_Get_Struct(rbObject, PyStruct, cObject);

  cReturn = PySys_SetObject(cName, cObject->pObject);

  rReturn = INT2NUM(cReturn);

  return rReturn;

}


inline
void Init_RubyPySys() {
  rb_define_module_function(mRubyPyApi, "sysGetObject", &rpGetObject, 1);
  rb_define_module_function(mRubyPyApi, "sysSetObject", &rpSetObject, 2);

}


