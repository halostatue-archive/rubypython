require 'blankslate'

class RubyPython::BlankObject < ::BlankSlate
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
