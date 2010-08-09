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
    @string = RubyPython::PyAPI.import 'string'
    @urllib2 = RubyPython::PyAPI.import 'urllib2'
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
      type, input, output = arr
      output ||= input

      it "should faithfully unwrap #{type}" do
        described_class.new(input).rubify.should == output
      end

    end

    #perhaps move this
    it "should raise 'Unsupported' error when unable to convert object" do
      lambda do
        request = @urllib2.getAttr('Request')
        request.rubify
      end.should raise_exception(RubyPython::PyAPI::Conversion::UnsupportedConversion)
    end

  end #rubify

  describe "#hasAttr" do
    it "should return true when object has the requested attribute" do
      @string.hasAttr("ascii_letters").should be_true
    end

    it "should return false when object does not have the requested attribute" do
      @string.hasAttr("nonExistentThing").should be_false
    end
  end

  describe "#getAttr" do
    it "should fetch requested object attribute" do 
      ascii_letters = @string.getAttr "ascii_letters"
      ascii_letters.rubify.should == "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    end

    it "should return a PyObject instance" do
      ascii_letters = @string.getAttr "ascii_letters"
      ascii_letters.should be_kind_of(described_class)
    end
  end

  describe "#setAttr" do 
    it "should modify the specified attribute of the object" do
      pyNewLetters = described_class.new "RbPy"
      @string.setAttr "ascii_letters", pyNewLetters
      @string.getAttr("ascii_letters").rubify.should == pyNewLetters.rubify
    end

    it "should create the requested attribute if it doesn't exist" do 
      pyNewString = described_class.new "python"
      @string.setAttr "ruby", pyNewString
      @string.getAttr("ruby").rubify.should == pyNewString.rubify
    end
  end

  describe "#cmp" do

    before do
      @less = described_class.new 5
      @greater = described_class.new 10
      @less_dup = described_class.new 5
    end

    it "should return 0 when objects are equal" do
      @less.cmp(@less_dup).should == 0
    end

    it "should change sign under interchange of arguments" do 
      @less.cmp(@greater).should == -@greater.cmp(@less)
    end

    it "should return -1 when first object is less than the second" do
      @less.cmp(@greater).should == -1
    end
    
    it "should return 1 when first object is greater than the second" do
      @greater.cmp(@less).should == 1
    end
  end

  describe "#makeTuple" do
    #Try to expand coverage here
    it "should wrap single arguments in a tuple" do
      arg = described_class.new AString
      described_class.makeTuple(arg).rubify.should == [AString]
    end
  end

  describe "#callObject" do
    #Expand coverage types
    it "should execute wrapped object with supplied arguments" do
      arg = described_class.new AnInt
      argt = described_class.makeTuple arg

      builtin = RubyPython::PyAPI.import "__builtin__"
      stringClass = builtin.getAttr "str"
      stringClass.callObject(argt).rubify.should == AnInt.to_s
    end
  end

  describe "#newList" do
    it "should wrap supplied args in a Python list" do
      args = AnArray.map do |obj|
        described_class.new obj
      end
      described_class.newList(*args).rubify.should == AnArray
    end
  end

end
