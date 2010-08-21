# rubypython

* htp://rubypython.rubyforge.org

## DESCRIPTION:

RubyPython is a bridge between the Ruby and Python interpreters. It embeds a
running Python interpreter in the applications process using FFI and
provides a means for wrapping and converting Python objects.
 
## FEATURES/PROBLEMS:

Features:

* Can handle simple conversion of Python builtin types to Ruby builtin types and vice versa
* Can import Python modules
* Can execute arbitrary methods on imported modules and return the result
* Python objects can be treated as Ruby objects!
* Python's standard library available to you from within Ruby.

## SYNOPSIS:
    RubyPython.start
    cPickle = RubyPython.import("cPickle")
    p cPickle.dumps("RubyPython is awesome!")
    RubyPython.stop
	
## REQUIREMENTS:
	
* Python >= 2.4, < 3.0
* Ruby >= 1.8.6

Note: RubyPython has been tested on Mac OS 10.5.x
	
	
## INSTALL:

[sudo] gem install rubypython

## DOCUMENTATION:

The documentation should provide a reasonable description of how to use RubyPython.
Starting with version 0.3.x there are two modes of operation: default and
legacy. These are described in the docs.
	
## LICENSE:

(The MIT License)

Copyright (c) 2008 Zach Raines

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
