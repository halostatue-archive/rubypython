#include "py_dict.h"
#include "py_object.h"

RUBY_EXTERN VALUE mRubyPyApi;
RUBY_EXTERN VALUE cRubyPyObject;
RUBY_EXTERN VALUE nilVal;

static
VALUE rpDictContains(VALUE mod, VALUE rbPyDict, VALUE rbPyKey) {
    PyStruct* cKey;
    PyStruct* cDict;
    
    VALUE retVal;
    
    Data_Get_Struct(rbPyDict, PyStruct, cDict);
    Data_Get_Struct(rbPyKey, PyStruct, cKey);
    
    if(PyDict_Contains(cDict->pObject, cKey->pObject))
        retVal = Qtrue;
    else
        retVal = Qfalse;
    
    return retVal;
}

static
VALUE rpDictGetItem(VALUE mod, VALUE rbPyDict, VALUE rbPyKey) {
    PyStruct* cKey;
    PyStruct* cDict;
    PyStruct* cRetVal;
    
    PyObject* pyRetVal;
    
    VALUE retVal;
    
    Data_Get_Struct(rbPyDict, PyStruct, cDict);
    Data_Get_Struct(rbPyKey, PyStruct, cKey);
    
    pyRetVal = PyDict_GetItem(cDict->pObject, cKey->pObject);
    
    retVal = rb_class_new_instance(1, &nilVal, cRubyPyObject);
    
    Data_Get_Struct(retVal, PyStruct, cRetVal);
    
    cRetVal->pObject = pyRetVal;
    
    return retVal;
}

static
VALUE rpDictSetItem(VALUE mod, VALUE rbPyDict, VALUE rbPyKey,
                    VALUE rbPyItem) {
    int status;
    
    VALUE retVal;
    
    PyStruct* cKey;
    PyStruct* cDict;
    PyStruct* cItem;
    
    Data_Get_Struct(rbPyDict, PyStruct, cDict);
    Data_Get_Struct(rbPyKey, PyStruct, cKey);
    Data_Get_Struct(rbPyItem, PyStruct, cItem);
    
    status =PyDict_SetItem(cDict->pObject,
                   cKey->pObject,
                   cItem->pObject);
    if(status)
        retVal = Qtrue;
    else
        retVal = Qfalse;
        
    return retVal;
    
}

inline
void Init_RubyPyDict() {
    rb_define_module_function(mRubyPyApi, "dictContains",
                              &rpDictContains, 2);
    rb_define_module_function(mRubyPyApi, "dictGetItem",
                              &rpDictGetItem, 2);
    rb_define_module_function(mRubyPyApi, "dictSetItem",
                              &rpDictSetItem, 3);
}