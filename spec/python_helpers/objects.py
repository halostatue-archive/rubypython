#!/usr/bin/env python

def identity(object):
  return object

def apply_callback(callback, args):
    return callback(*args)

def named_args(arg1, arg2):
  return [arg2*2, arg1*2]

class RubyPythonMockObject:
  STRING = "STRING"
  STRING_LIST = ["STRING1", "STRING2"]
  INT = 1
  INT_LIST = [1,1]
  FLOAT = 1.0
  FLOAT_LIST = [1.0,1.0]

  def square_elements(self, aList):
    return [x**2 for x in aList]

  def sum_elements(self, aList):
    return sum(aList)

  def __eq__(self, other):
    if type(self) == type(other):
      return True
    else:
      return False

class NewStyleClass(object):
  def a_method(self):
    pass

an_int = 1
a_char = 'a'
a_float = 1.0
a_symbol = 'sym'
a_string = "STRING"
a_string_with_nulls = "STRING\0WITH\0NULLS"
an_array = a_list = [an_int, a_char, a_float, a_string]
a_hash = a_dict = { an_int: an_int, a_char: a_char, a_symbol: a_float,
    a_string: a_string }
true = python_True = True
false = python_False = False
nil = python_None = None
a_tuple = tuple(a_list)
