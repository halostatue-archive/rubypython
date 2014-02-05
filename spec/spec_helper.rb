require 'rspec'
require 'rubypython'

module RPTest
  AString = "STRING"
  AStringWithNULLs = "STRING\0WITH\0NULLS"
  AnInt = 1
  AChar = 'a'
  AFloat = 1.0
  AnArray = [AnInt, AChar, AFloat, AString]
  ATuple = RubyPython::Tuple.tuple(AnArray)
# ATuple << AnInt << AChar << AFloat << AString
  ASym = :sym
  AHash = {
    AnInt => AnInt,
    AChar.to_sym => AChar,
    ASym => AFloat,
    AString => AString
  }
  AConvertedHash = Hash[*AHash.map do |k, v|
    key = k.is_a?(Symbol) ? k.to_s : k
    [key, v]
  end.flatten]
  AProc = Proc.new { |a1, a2| a1 + a2 }
  def self.a_method(a1, a2)
    a1 + a2
  end
  AMethod = method(:a_method)

  Helpers = File.join(File.dirname(__FILE__), 'python_helpers')
end

def run_python_command(cmd)
  %x(python -c '#{cmd}').chomp
end

def get_refcnt(pobject)
  raise 'Cannot work with a nil object' if pobject.nil?

  if pobject.kind_of? RubyPython::RubyPyProxy
    pobject = pobject.pObject.pointer
  elsif pobject.kind_of? RubyPython::PyObject
    pobject = pobject.pointer
  end
  RubyPython::Macros.Py_REFCNT pobject
end

RSpec.configure do |config|
  if RUBY_VERSION < '1.9.2'
    config.filter_run_excluding :ruby_version => '1.9'
  end

  config.before(:all) do
    class RubyPython::RubyPyProxy
      [:class].each { |m| reveal(m) }
    end
  end

  config.before(:all) do
    RubyPython.start

    @sys = RubyPython.import 'sys'
    @sys.path.append RPTest::Helpers
    @objects = RubyPython.import 'objects'
    @basics = RubyPython.import 'basics'
  end

  config.before(:all, :self_start => true) do
    RubyPython.stop
  end

  config.after(:all) do
    RubyPython.stop
  end
end
