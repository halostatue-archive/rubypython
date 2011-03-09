# A class that wraps a python executable. Replaces lots of constants under
# RubyPython::Python. For internal use only.
class RubyPython::PythonExec
  def initialize(python_executable)
    @python = python_executable
    if @python.nil?
      @python = %x(python -c "import sys; print sys.executable").chomp
    end

    @version = run_command 'import sys; print "%d.%d" % sys.version_info[:2]'
    @realname = "#{@python}#{@version}"
    @sys_prefix = run_command 'import sys; print sys.prefix'
    @library = find_python_lib
    self.freeze
  end

  def find_python_lib
    # By default, the library name will be something like
    # libpython2.6.so, but that won't always work.
    libbase = "#{FFI::Platform::LIBPREFIX}#{@realname}"
    libext = FFI::Platform::LIBSUFFIX
    libname = "#{libbase}.#{libext}"

    # We may need to look in multiple locations for Python, so let's
    # build this as an array.
    locations = [ File.join(@sys_prefix, "lib", libname) ]

    if FFI::Platform.mac?
      # On the Mac, let's add a special case that has even a different
      # libname. This may not be fully useful on future versions of OS
      # X, but it should work on 10.5 and 10.6. Even if it doesn't, the
      # next step will (/usr/lib/libpython<version>.dylib is a symlink
      # to the correct location).
      locations << File.join(@sys_prefix, "Python")
      # Let's also look in the location that was originally set in this
      # library:
      File.join(@sys_prefix, "lib", "#{@realname}", "config", libname)
    end

    if FFI::Platform.unix?
      # On Unixes, let's look in some standard alternative places, too.
      # Just in case.
      locations << File.join("/opt/local/lib", libname)
      locations << File.join("/opt/lib", libname)
      locations << File.join("/usr/local/lib", libname)
      locations << File.join("/usr/lib", libname)
    end

    # Let's add alternative extensions; again, just in case.
    locations.dup.each do |location|
      path = File.dirname(location)
      base = File.basename(location, libext)
      locations << File.join(path, "#{base}.so")    # Standard Unix
      locations << File.join(path, "#{base}.dylib") # Mac OS X
      locations << File.join(path, "#{base}.dll")   # Windows
      locations << File.join(path, "#{base}.a")     # Non-DLL
    end

    # Remove redundant locations
    locations.uniq!

    library = nil

    locations.each do |location|
      if File.exists? location
        library = location
        break
      end
    end

    library
  end
  private :find_python_lib

  # The python executable to use.
  attr_reader :python
  # The realname of the python executable (with version).
  attr_reader :realname
  # The sys.prefix for Python.
  attr_reader :sys_prefix
  # The Python library.
  attr_reader :library

  # Run a Python command-line command.
  def run_command(command)
    %x(#{@python} -c '#{command}').chomp
  end

  def to_s
    @realname
  end
end
