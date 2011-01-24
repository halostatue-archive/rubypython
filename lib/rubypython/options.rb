module RubyPython
  #A hash for storing RubyPython execution options.
  @options = {}

  NEED_RELOAD = [
    :python_exe,
    :python_lib
  ]

  class << self
    #Allows one to set options for RubyPython's execution. Parameters 
    #may be set either by supplying a hash argument or by supplying 
    #a block and calling setters on the provided OpenStruct.
    #@param [Hash] a hash of options to set
    #@return [Hash] a copy of the new options hash
    def configure(hash={})
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
      @options.merge!(hash)

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

    def clear_options
      @options.clear
    end

  end
end
