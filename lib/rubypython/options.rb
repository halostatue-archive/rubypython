module RubyPython
  #A hash for storing RubyPython execution options.
  @options = {}

  #A list of options which require the Python library to be reloaded.
  NEED_RELOAD = [
    :python_exe,
    :python_lib
  ]

  class << self
    #Allows one to set options for RubyPython's execution. Parameters 
    #may be set either by supplying a hash argument or by supplying 
    #a block and calling setters on the provided OpenStruct.
    #@param [Hash] opts a hash of options to set
    #@option opts [String] :python_exe The python executable for 
    #  the python version you wish to use. Can be anything in your 
    #  execution path as well as a local or relative path.
    #@option opts [String] :python_lib The full path to the python 
    #  library you wish to load.
    #@return [Hash] a copy of the new options hash
    #
    #@example
    #  irb(main):001:0> RubyPython.run do
    #  irb(main):002:1*   RubyPython.import('sys').version.rubify.to_f
    #  irb(main):003:1> end
    #  => 2.7
    #  irb(main):004:0> RubyPython.configure :python_exe => 'python2.6'
    #  => {:python_exe=>"python2.6"}
    #  irb(main):005:0> RubyPython.run do
    #  irb(main):006:1*   RubyPython.import('sys').version.rubify.to_f
    #  irb(main):007:1> end
    #  => 2.6
    #  
    def configure(opts={})
      old_values = @options.select { |k,v| NEED_RELOAD.include? k }

      if block_given?
        ostruct = OpenStruct.new @options
        yield ostruct
        @options = Hash[*ostruct.instance_eval do 
          @table.map do |k, v|
            [k.to_sym, v]
          end.flatten
        end]
      end
      @options.merge!(opts)

      @reload = true if NEED_RELOAD.any? { |k| @options[k] != old_values[k] } 
      options
    end

    #Returns a copy of the hash currently being used to determine run 
    #options. This allows the user to determine what options have been 
    #set. Modification of options should be done via the configure 
    #method.
    #@return [Hash] a copy of the current options hash
    def options
      @options.dup
    end

    #Reset the options hash.
    #@return [void]
    def clear_options
      @options.clear
    end

  end
end
