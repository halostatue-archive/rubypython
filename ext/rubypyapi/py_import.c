#include "py_import.h"
#include "py_object.h"

RUBY_EXTERN VALUE cRubyPyObject;
RUBY_EXTERN VALUE mRubyPyApi;

RUBY_EXTERN VALUE nilVal;

static
VALUE rpPy_Import(VALUE mod, VALUE mname) {
    char* cName;
    VALUE rbModule;
    PyObject* pModule;
    PyStruct* pyStruct;
    
    cName = STR2CSTR(mname);
    
    pModule = PyImport_ImportModule(cName);
    
    rbModule = rb_class_new_instance(1, &nilVal, cRubyPyObject);
        
    Data_Get_Struct(rbModule, PyStruct, pyStruct);
    
    Py_XDECREF(pyStruct->pObject);
    
    pyStruct->pObject = pModule;
    
    return rbModule;
    
}

inline
void Init_RubyPyImport() {
    rb_define_module_function(mRubyPyApi, "import", rpPy_Import, 1);
}