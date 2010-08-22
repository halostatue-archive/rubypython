begin
  require 'spec'
  require 'ffi'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
  require 'ffi'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubypython'

module TestConstants
  #REDEFINE THESE SO THEY ARE VISIBILE
    AString = "STRING"
    AnInt = 1
    AChar = 'a'
    AFloat = 1.0
    AnArray = [AnInt, AChar, AFloat, AString]
    ASym = :sym
    AHash = {
      AnInt => AnInt,
      AChar.to_sym => AChar,
      ASym => AFloat,
      AString => AString
    }
    AConvertedHash = Hash[*AHash.map do |k, v|
      key = k.is_a?(Symbol)? k.to_s : k
      [key,v]
    end.flatten]
end

def run_python_command(cmd)
  IO.popen("python -c '#{cmd}'") { |f| f.gets.chomp}
end

class RubyPython::RubyPyProxy
  [:should, :should_not, :class].each { |m| reveal(m) }
end

share_as :RubyPythonStartStop do
  before do
    RubyPython.start
  end

  after do
    RubyPython.stop
  end
end

