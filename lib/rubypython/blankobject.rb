require 'blankslate'

module RubyPython
  #An object to be used as a base class for Proxy classes.
  #It is necessary to define this because no such class exists in Ruby
  #1.8.x
  class BlankObject < BlankSlate
    class << self
      def hide(name)
        if instance_methods.include?(name) and
          name.to_s !~ /^(__|instance_eval|object_id)/
          @hidden_methods ||= {}
          @hidden_methods[name.to_sym] = instance_method(name)
          undef_method name
        end
      end
    end

    instance_methods.each { |m| hide(m) }
  end
end
