## 0.3.0 2010-09-xx
* Major Enhancements
  * Version 0.3.0 represents an almost complete rewrite of the RubyPython codebase.
  * A native C extension is no longer required. RubyPython uses the 'ffi' gem.
  * RubyPython by default now returns proxy instances for all Ruby objects. See the documentation for more information.
* Compatibility Updates
  * Version 0.3.0 was created with the goal of being compatible with as many Ruby versions as possible. It should at the very least run on MRI 1.8.6 - 1.9.1.
  * A legacy mode option has been added to provide partial compatibility with version 0.2.x.

## 0.2.10 2010-07-08
* Bug Fixes
	* Made some changes to how the native extension is configured and build.

## 0.2.9 2009-10-19
* Minor Enhancements
	* Updated the C code to make it cleaner, more readable, and more maintainable.

## 0.2.8 2009-10-05
* Bug Fixes
	* Some test files were improperly formatted (minor bug fix).

## 0.2.7 2009-3-30
* Bug Fixes
	* Fixed some bugs which caused rubypython to be unable to determine python version correctly.

## 0.2.6 2009-3-19
* Bug Fixes
	* Further updates to increase compatibility with 1.9.

## 0.2.5 2009-3-18
* Bug Fixes
	* Updated to build and run under Ruby 1.9.

## 0.2.4 2008-10-24
* Major Enhancements
	* Provided setter methods for object attributes. Python object attributes can now be set from within ruby.
	* Made wrapper classes a subclass of custom made blank object class to try to avoid name collisions.
* Bug Fix
	* Changed part of extconf.rb file that would not work under windows.

## 0.2.3 2008-08-29
* 2 Major Enhancements
	* Introduced PyMain object as a singleton wrapper for the Python __main__ and __builtin__ modules.
	* Introduced block functionality for PyMain object.
	
* Compatibility Updates
	* Changed some declarations in the C code to make RubyPython more compatible with the style conventions of the Ruby C API.
	* Update how RubyPython locates the Python headers and library.
* 1 Bug Fix
	* Fixed an error in ptor.c that might have prevented RubyPython from building correctly on certain systems.
		

## 0.2.2 2008-08-07
* Major Enhancements
	* Wrapped classes and instances should now behave as expected.
	* Gave RubyPyClasses a "new" method for creating instances.
	* Callable class can now be called provided that at least one argument is given
	* A wrapped object's respond_to? method now has some relation to its actual methods.
	
* Bug fixes
	* Fixed bug with inspect method of RubyPyObject that caused a bus error when inspecting certain objects


## 0.2.1 2008-08-02
* 1 Bug Fix
	* Incorrect require fixed

## 0.2.0 2008-08-02
* 3 major enhancements
	* RubyPython can now effectively convert or wrap most types from Python.
	* Errors in the Python interpreter are relayed to Ruby errors.
	* Less seg faults by mass.
* Bug Fixes
	* RubyPython.run did not work correctly. This is fixed now.
	* Cleanup in RubyPython.stop fixes some issues in RubyPythonBridge.stop

## 0.1.0 2008-08-01
* A lot of major enhancements
	* Too many to name. Hey I'm still developing

## 0.0.1 2008-07-30

* 1 major enhancement:
  * Initial release
