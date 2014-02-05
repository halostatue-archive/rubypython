require 'rubypython'

def import_cython
  pyximport = RubyPython.import('pyximport')
  pyximport.install

  sys = RubyPython.import('sys')
  sys.path.append File.dirname(__FILE__)
  sys
end

def try_cmod
  RubyPython.start
  import_cython
  cmod = RubyPython.import('c')
  cmod.C.foo
  RubyPython.stop
end

try_cmod
try_cmod
