# A class that represents a \Python executable.
#
# End users may get the instance that represents the current running \Python
# interpreter (from +RubyPython.python+), but should not directly
# instantiate this class.
class RubyPython::PythonExec
  # Based on the name of or path to the \Python executable provided, will
  # determine:
  #
  # * The full path to the \Python executable.
  # * The version of \Python being run.
  # * The system prefix.
  # * The main loadable \Python library for this version.
  def initialize(python_executable)
    @python = python_executable || "python"
    @python = %x(#{@python} -c "import sys; print sys.executable").chomp

    @version = run_command 'import sys; print "%d.%d" % sys.version_info[:2]'

    @realname = @python.dup
    if @realname !~ /#{@version}$/
      @realname = "#{@python}#{@version}"
    end
    @basename = File.basename(@realname)

    @sys_prefix = run_command 'import sys; print sys.prefix'
    @library = find_python_lib
  end

  def find_python_lib
    # By default, the library name will be something like
    # libpython2.6.so, but that won't always work.
    libbase = "#{FFI::Platform::LIBPREFIX}#{@basename}"
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
      # Just in case. Some Unixes don't include a .so symlink when they
      # should, so let's look for the base case of .so.1, too.
      [ libname, "#{libname}.1" ].each do |name|
        locations << File.join("/opt/local/lib", name)
        locations << File.join("/opt/lib", name)
        locations << File.join("/usr/local/lib", name)
        locations << File.join("/usr/lib", name)
      end
    end

    # Let's add alternative extensions; again, just in case.
    locations.dup.each do |location|
      path = File.dirname(location)
      base = File.basename(location, ".#{libext}")
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
  # The real name of the python executable (with version).
  attr_reader :realname
  # The sys.prefix for Python.
  attr_reader :sys_prefix
  # The Python library.
  attr_reader :library
  #  The version
  attr_reader :version

  # Run a Python command-line command.
  def run_command(command)
    %x(#{@python} -c '#{command}').chomp if @python
  end

  def to_s
    @realname
  end

  def inspect
    if @python
      "#<#{realname} #{sys_prefix}>"
    else
      "#<invalid interpreter>"
    end
  end

  def invalidate!
    @python = @version = @realname = @sys_prefix = @library = nil
  end
  private :invalidate!
end
