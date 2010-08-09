begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
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

