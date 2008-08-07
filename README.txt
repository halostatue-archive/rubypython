= rubypython

* htp://rubypython.rubyforge.org

== DESCRIPTION:

	RubyPython is a C bridge between Ruby and Python with a Ruby interface. It's aim is to make the power of the Python's great standard library available to Ruby programmers from within Ruby.

== FEATURES/PROBLEMS:

	Features:
	* Can handle simple conversion of Python builtin types to ruby builtin types and vice versa
	* Can import python modules
	* Can execute arbitrary methods on imported modules and return the result
	* Python objects can be treated as Ruby objects!
	* Python's standard library available to you from within ruby.

== SYNOPSIS:
	RubyPython.start
	cPickle=RubyPython.import("cPickle")
	p cPickle.dumps("RubyPython is awesome!")
	RubyPython.stop
	
== REQUIREMENTS:
	Python must be installed. Currently, RubyPython requires python2.5 but it may soon be  able to work on other platforms. I have only tested it on Mac OSX 10.5, so I'm not sure what parts may need correcting for other systems. 

== INSTALL:

	sudo gem install rubypython
	
== LICENSE:

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