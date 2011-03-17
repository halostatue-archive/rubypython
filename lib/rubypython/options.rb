require 'ostruct'

module RubyPython
  # A hash for storing RubyPython execution options.
  @options = {}

  # A list of options which require the \Python library to be reloaded.
  NEED_RELOAD = [ :python_exe ] #:nodoc
  # 20110316 AZ: This option has been removed because it isn't supported in
  # the current code.
  # :python_lib -> The full path to the python library you wish to load.

  class << self
    # Allows one to set options for RubyPython's execution. Parameters may
    # be set either by supplying a hash argument or by supplying a block and
    # calling setters on the provided OpenStruct. Returns a copy of the
    # updated options hash.
    #
    # [options] A Hash of options to set.
    #
    # The option currently supported is:
    # [:python_exe] The name of or path to the \Python executable for the
    # version of \Python you wish to use.
    # 
    #   RubyPython.run do
    #     RubyPython.import('sys').version.rubify.to_f # => 2.7
    #   end
    #
    #   RubyPython.configure :python_exe => 'python2.6'
    #   # => { :python_exe => "python2.6" }
    #   RubyPython.run do
    #     RubyPython.import('sys').version.rubify.to_f # => 2.6
    #   end
    #   
    # The options hash can also be passed directly to +RubyPython.start+,
    # +RubyPython.session+, or +RubyPython.run+.
    def configure(options = {})
      old_values = Hash[*@options.select { |k, v| NEED_RELOAD.include? k }]

      if block_given?
        ostruct = OpenStruct.new @options
        yield ostruct
        olist = ostruct.instance_variable_get('@table').map { |k, v| [ k.to_sym, v ] }
        @options = Hash[*olist]
      end
      @options.merge!(options)

      @reload = true if NEED_RELOAD.any? { |k| @options[k] != old_values[k] } 
      options
    end

    # Returns a copy of the hash currently being used to determine run
    # options. This allows the user to determine what options have been set.
    # Modification of options should be done via the configure method.
    def options
      @options.dup
    end

    # Reset the options hash.
    # @return [void]
    def clear_options
      @reload = @options.keys.any? { |k| NEED_RELOAD.include? k }
      @options.clear
    end
  end
end
