require File.dirname(__FILE__) + '/spec_helper.rb'

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

describe RubyPython::PyAPI, "when starting/stopping interpreter" do
  
  it "start and stop only once" do
    RubyPython::PyAPI.start.should be_true
    RubyPython::PyAPI.start.should be_false
    RubyPython::PyAPI.stop.should be_true
    RubyPython::PyAPI.stop.should be_false
  end
  
end

describe RubyPython::PyAPI::PyObject do
  include TestConstants
  before do
    RubyPython::PyAPI.start
  end

  after do
    RubyPython::PyAPI.stop
  end

  describe "#new" do

    [
      ["a string", AString],
      ["an int", AnInt],
      ["a float", AFloat],
      ["an array", AnArray],
      ["a symbol", ASym],
      ["a hash", AHash]
    ].each do |title, obj|
      it "should wrap #{title}" do
        described_class.new(obj).should be_instance_of(described_class)
      end
    end


  end #new

  describe "#rubify" do

    [
      ["a string", AString],
      ["an int", AnInt],
      ["a float", AFloat],
      ["an array", AnArray],
      ["a symbol", ASym, ASym.to_s],
      ["a hash", AHash, AConvertedHash]
    ].each do |arr|
      p arr
      type, input, output = arr
      output ||= input

      it "should faithfully unwrap #{type}" do
        described_class.new(input).rubify.should == output
      end

    end

    #perhaps move this
    it "should raise 'Unsupported' error when unable to convert object" do
      lambda do
        urllib2 = RubyPython::PyAPI.import 'urllib2'
        request = urllib2.getAttr('Request')
        request.rubify
      end.should raise_exception(RubyPython::PyAPI::Conversion::UnsupportedConversion)
    end

  end #rubify

  describe "#hasAttr" do
    it "should return true when object has the requested attribute" do
      pyStringModule = RubyPython::PyAPI.import("string")
      pyStringModule.hasAttr("ascii_letters").should be_true
    end

  end

end
