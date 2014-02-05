cdef class C:
    @classmethod
    def foo(cls, a=5):
        print a, cls
        print cls, a
