# -*- ruby encoding: utf-8 -*-

class RubyPython::InvalidInterpreter < Exception
end

##
# An instance of this class represents information about a particular
# \Python interpreter.
#
# This class represents the current Python interpreter.
# A class that represents a \Python executable.
#
# End users may get the instance that represents the current running \Python
# interpreter (from +RubyPython.python+), but should not directly
# instantiate this class.
class RubyPython::Interpreter

  ##
  # Compare the current Interpreter to the provided Interpreter or
  # configuration hash. A configuration hash will be converted to an
  # Interpreter object before being compared.
  # :python_exe basename is used. If comparing against another Interpreter
  # object, the Interpreter basename and version are used.
  def ==(other)
    other = self.class.new(other) if other.kind_of? Hash
    return false unless other.kind_of? self.class
    (self.version == other.version) && (self.version_name == other.version_name)
  end

  ##
  # Create a new instance of an Interpreter instance describing a particular
  # \Python executable and shared library.
  #
  # Expects a hash that matches the configuration options provided to
  # RubyPython.start; currently only one value is recognized in that hash:
  #
  # * <tt>:python_exe</tt>: Specifies the name of the python executable to
  #   run.
  def initialize(options = {})
    @python_exe = options[:python_exe]
    # Windows: 'C:\\Python27\python.exe'
    # Mac OS X: '/usr/bin/

    # The default interpreter might be python3 on some systems
    rc, majorversion = runpy "import sys; print(sys.version_info[0])"
    if majorversion == "3"
      warn "The python interpreter is python 3, switching to python2"
      @python_exe = "python2"
    end

    rc, @python     = runpy "import sys; print sys.executable"
    if rc.exitstatus.nonzero?
      raise RubyPython::InvalidInterpreter, "An invalid interpreter was specified."
    end
    rc, @version    = runpy "import sys; print '%d.%d' % sys.version_info[:2]"
    rc, @sys_prefix = runpy "import sys; print sys.prefix"

    if ::FFI::Platform.windows?
      flat_version  = @version.tr('.', '')
      basename      = File.basename(@python, '.exe')

      if basename =~ /(?:#{@version}|#{flat_version})$/
        @version_name = basename
      else
        @version_name = "#{basename}#{flat_version}"
      end
    else
      basename = File.basename(@python)
      if basename =~ /#{@version}/
        @version_name = basename
      elsif basename.end_with?("2")
        @version_name = "#{basename[0..-2]}#{@version}"
      else
        @version_name = "#{basename}#{@version}"
      end
    end

    @library = find_python_lib
  end

  def find_python_lib
    # By default, the library name will be something like
    # libpython2.6.so, but that won't always work.
    @libbase = "#{::FFI::Platform::LIBPREFIX}#{@version_name}"
    @libext = ::FFI::Platform::LIBSUFFIX
    @libname = "#{@libbase}.#{@libext}"

    # We may need to look in multiple locations for Python, so let's
    # build this as an array.
    @locations = [ File.join(@sys_prefix, "lib", @libname) ]

    if ::FFI::Platform.mac?
      # On the Mac, let's add a special case that has even a different
      # @libname. This may not be fully useful on future versions of OS
      # X, but it should work on 10.5 and 10.6. Even if it doesn't, the
      # next step will (/usr/lib/libpython<version>.dylib is a symlink
      # to the correct location).
      @locations << File.join(@sys_prefix, "Python")
      # Let's also look in the location that was originally set in this
      # library:
      File.join(@sys_prefix, "lib", "#{@realname}", "config", @libname)
    end

    if ::FFI::Platform.unix?
      # On Unixes, let's look in some standard alternative places, too.
      # Just in case. Some Unixes don't include a .so symlink when they
      # should, so let's look for the base cases of .so.1 and .so.1.0, too.
      [ @libname, "#{@libname}.1", "#{@libname}.1.0" ].each do |name|
        if ::FFI::Platform::ARCH != 'i386'
          @locations << File.join("/opt/local/lib64", name)
          @locations << File.join("/opt/lib64", name)
          @locations << File.join("/usr/local/lib64", name)
          @locations << File.join("/usr/lib64", name)
        end
        @locations << File.join("/opt/local/lib", name)
        @locations << File.join("/opt/lib", name)
        @locations << File.join("/usr/local/lib", name)
        @locations << File.join("/usr/lib", name)
      end
    end

    if ::FFI::Platform.windows?
      # On Windows, the appropriate DLL is usually be found in
      # %SYSTEMROOT%\system or %SYSTEMROOT%\system32; as a fallback we'll
      # use C:\Windows\system{,32} as well as the install directory and the
      # install directory + libs.
      system_root = File.expand_path(ENV['SYSTEMROOT']).gsub(/\\/, '/')
      @locations << File.join(system_root, 'system', @libname)
      @locations << File.join(system_root, 'system32', @libname)
      @locations << File.join("C:/WINDOWS", "System", @libname)
      @locations << File.join("C:/WINDOWS", "System32", @libname)
      @locations << File.join(sys_prefix, @libname)
      @locations << File.join(sys_prefix, 'libs', @libname)
      @locations << File.join(system_root, "SysWOW64", @libname)
      @locations << File.join("C:/WINDOWS", "SysWOW64", @libname)
    end

    # Let's add alternative extensions; again, just in case.
    @locations.dup.each do |location|
      path = File.dirname(location)
      base = File.basename(location, ".#{@libext}")
      @locations << File.join(path, "#{base}.so")    # Standard Unix
      @locations << File.join(path, "#{base}.dylib") # Mac OS X
      @locations << File.join(path, "#{base}.dll")   # Windows
    end

    # Remove redundant locations
    @locations.uniq!

    library = nil

    @locations.each do |location|
      if File.exists? location
        library = location
        break
      end
    end

    library
  end
  private :find_python_lib

  def valid?
    if @python.nil? or @python.empty?
      false
    elsif @library.nil? or @library.empty?
      false
    else
      true
    end
  end

  ##
  # The name of the \Python executable that is used. This is the value of
  # 'sys.executable' for the \Python interpreter provided in
  # <tt>:python_exe</tt> or 'python' if it is not provided.
  #
  # On Mac OS X Lion (10.7), this value is '/usr/bin/python' for 'python'.
  attr_reader :python
  ##
  # The version of the \Python interpreter. This is a decimalized version of
  # 'sys.version_info[:2]' (such that \Python 2.7.1 is reported as '2.7').
  attr_reader :version
  ##
  # The system prefix for the \Python interpreter. This is the value of
  # 'sys.prefix'.
  attr_reader :sys_prefix
  ##
  # The basename of the \Python interpreter with a version number. This is
  # mostly an intermediate value used to find the shared \Python library,
  # but /usr/bin/python is often a link to /usr/bin/python2.7 so it may be
  # of value. Note that this does *not* include the full path to the
  # interpreter.
  attr_reader :version_name

  # The \Python library.
  attr_reader :library

  # Run a Python command-line command.
  def runpy(command)
    i = @python || @python_exe || 'python'
    if ::FFI::Platform.windows?
      o = %x(#{i} -c "#{command}" 2> NUL:)
    else
      o = %x(#{i} -c "#{command}" 2> /dev/null)
    end

    [ $?, o.chomp ]
  end
  private :runpy

  def inspect(debug = false)
    if debug
      debug_s
    elsif @python
      "#<#{self.class}: #{python} v#{version} #{sys_prefix} #{version_name}>"
    else
      "#<#{self.class}: invalid interpreter>"
    end
  end

  def debug_s(format = nil)
    system = ""
    system << "windows " if ::FFI::Platform.windows?
    system << "mac " if ::FFI::Platform.mac?
    system << "unix " if ::FFI::Platform.unix?
    system << "unknown " if system.empty?

    case format
    when :report
      s = <<-EOS
python_exe:   #{@python_exe}
python:       #{@python}
version:      #{@version}
sys_prefix:   #{@sys_prefix}
version_name: #{@version_name}
platform:     #{system.chomp}
library:      #{@library.inspect}
  libbase:    #{@libbase}
  libext:     #{@libext}
  libname:    #{@libname}
  locations:  #{@locations.inspect}
      EOS
    else
      s = "#<#{self.class}: "
      s << "python_exe=#{@python_exe.inspect} "
      s << "python=#{@python.inspect} "
      s << "version=#{@version.inspect} "
      s << "sys_prefix=#{@sys_prefix.inspect} "
      s << "version_name=#{@version_name.inspect} "
      s << system
      s << "library=#{@library.inspect} "
      s << "libbase=#{@libbase.inspect} "
      s << "libext=#{@libext.inspect} "
      s << "libname=#{@libname.inspect} "
      s << "locations=#{@locations.inspect}"
    end

    s
  end
end
