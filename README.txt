= rubypython

* htp://rubypython.rubyforge.org

== DESCRIPTION:

	RubyPython is a a C bridge between ruby and python with a ruby interface.

== FEATURES/PROBLEMS:

	Features:
	* Can handle simple conversion of Python builtin types to ruby builtin types and vice versa
	* Can import python module
	* Can execute arbitrary methods on imported modules and return the result
	
	Problems:
	* Issues dealing with classes and instances
	* Issues with the run method

== SYNOPSIS:
	RubyPython.start
	cPickle=RubyPython.import("cPickle")
	p cPickle.dumps("RubyPython is awesome!")
	RubyPython.stop
	
== REQUIREMENTS:


== INSTALL:

	sudo gem install rubypython
	
== LICENSE:

(The MIT License)

Copyright (c) 2008 FIXME full name

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