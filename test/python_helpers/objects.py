#!/usr/bin/env python

def identity(object):
    return object

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
