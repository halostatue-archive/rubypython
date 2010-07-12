#include "config.h"

#ifndef _RP_ERROR_H_
#define _RP_ERROR_H_

void rpPythonError();

void rpRubyPyError(char*);
inline void Init_RubyPyError();

#endif /* _RP_ERROR_H_ */
