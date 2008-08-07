#ifndef _PYTHON_H_
#define _PYTHON_H_

#ifdef HAVE_PYTHON_H
#include "Python.h"

#else
#ifdef HAVE_PYTHON2_5_PYTHON_H
#include "python2.5/Python.h"

#else
#ifdef HAVE_PYTHON2_4_PYTHON_H
#include "python2.4/Python.h"
#endif
#endif
#endif


#endif /* _PYTHON_H_ */

#ifndef _STDLIB_H_
#define _STDLIB_H_
#include "stdlib.h"
#endif /* _STDLIB_H_ */

#ifndef _RUBY_H_
#define _RUBY_H_
#include "ruby.h"
#endif /* _RUBY_H_ */