require 'blankslate'

# This document is the basis of the RubyPyProxy precisely because it hides
# the implementation of so many things that should be forwarded on to the
# Python object. This class is for internal use only.
#
# Note that in Ruby 1.9, BasicObject might be a better choice, but there are
# some decisions made in the rest of the library that make this harder. I
# don't see a clean way to integrate both Ruby 1.8 and 1.9 support for this.
class RubyPython::BlankObject < ::BlankSlate #:nodoc:
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
