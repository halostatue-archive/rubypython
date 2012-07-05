#!/usr/bin/env python

def iterate_list():
  for item in [ 1, 2, 3 ]:
    yield item

def identity(object):
  return object

def simple_callback(callback, value):
  return callback(value)

def simple_generator(callback):
  output = []
  for i in callback():
    output.append(i)
  return output

def named_args(arg1, arg2):
  return [arg1, arg2]

def expects_tuple(tvalue):
  return isinstance(tvalue, tuple)
