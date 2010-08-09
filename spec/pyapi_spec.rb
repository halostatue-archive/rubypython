require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyPython::PyAPI,  "when starting/stopping interpreter" do
  it "should start and stop only once" do
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

describe RubyPython::PythonError do
  before do
    RubyPython::PyAPI.start
  end

  after do
    RubyPython::PyAPI.stop
  end

  describe "#error?" do
    it "should return false when no error has occured" do
      described_class.error?.should be_false
    end

    it "should return true when an error has occured" do
      RubyPython::PyAPI.import("wat")
      described_class.error?.should be_true
    end
  end

  describe "#clear" do
    it "should reset the Python error flag" do
      RubyPython::PyAPI.import("wat")
      described_class.clear
      described_class.error?.should be_false
    end

    it "should not barf when there is no error" do
      lambda {described_class.clear}.should_not raise_exception
    end
  end


  describe "#fetch" do
    it "should make availible Python error type" do
      RubyPython::PyAPI.import("wat")
      rbType, rbValue, rbTraceback = described_class.fetch
      rbType.getAttr("__name__").rubify.should == "ImportError"
    end
  end

end

describe RubyPython::PyAPI::RubyPyProxy do
  include TestConstants

  before do
    RubyPython::PyAPI.start
    @a = RubyPython::PyAPI::PyObject.new "a"
    @b = RubyPython::PyAPI::PyObject.new "b"
    @builtin = RubyPython::PyAPI.import "__builtin__"
    @string = RubyPython::PyAPI.import "string"

    @two = 2
    @six = 6
  end

  after do
    RubyPython::PyAPI.stop
  end

  describe "#new" do
    it "should accept a PyObject instance" do
      rbPyObject = RubyPython::PyAPI::PyObject.new AString
      lambda {described_class.new rbPyObject}.should_not raise_exception
    end


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

      it "should convert #{type} to wrapped pObject" do
        described_class.new(input).pObject.rubify.should == output
      end

    end
  end

  describe "#rubify" do
    [
      ["a string", AString],
      ["an int", AnInt],
      ["a float", AFloat],
      ["an array", AnArray],
      ["a symbol", ASym],
      ["a hash", AHash]
    ].each do |title, obj|
      it "should faithfully unwrap #{title}" do
        pyObject = RubyPython::PyAPI::PyObject.new obj
        proxy = described_class.new pyObject
        proxy.rubify.should == pyObject.rubify
      end
    end
  end

  describe "method delegation" do

    it "should refer method calls to wrapped object" do
      aProxy = described_class.new(@a)
      bProxy = described_class.new(@b)
      aProxy.__add__(bProxy).rubify.should == (@a.rubify + @b.rubify)
    end

    it "should raise NoMethodError when method is undefined" do
      aProxy = described_class.new @a
      lambda {aProxy.wat []}.should raise_exception(NoMethodError)
    end

    it "should allow methods to be called with no arguments" do
      builtinProxy = described_class.new @builtin
      rbStrClass = builtinProxy.str
      rbStrClass.new.rubify.should == String.new
    end

    it "should fetch attributes when method name is an attribute" do
      pyLetters = @string.getAttr "ascii_letters"
      stringProxy = described_class.new @string
      stringProxy.ascii_letters.rubify.should == pyLetters.rubify
    end

    it "should set attribute if method call is a setter" do
      stringProxy = described_class.new @string
      stringProxy.letters = AString
      stringProxy.letters.rubify.should == AString
    end

    it "should return a class as a RubyPyClass" do
      urllib2 = RubyPython.import('urllib2')
      urllib2.Request.should be_a(RubyPython::PyAPI::RubyPyClass)
    end
  end

  describe "when used with an operator" do

    ['+', '-', '/', '*', '==', '<', '>', '<=', '>='].each do |op|
      it "should delegate #{op}" do
        @six.__send__(op, @two).should be_equal(6.__send__ op, 2)
      end
    end

  end

  it "should delegate object equality" do
    urllib_a = described_class.new RubyPython::PyAPI.import('urllib')
    urllib_b = described_class.new RubyPython::PyAPI.import('urllib')
    urllib_a.should == urllib_b
  end

end

describe RubyPython::PyAPI::RubyPyClass do
  before do
    RubyPython.start
  end

  after do
    RubyPython.stop
  end

  describe "#new" do
    it "should return a RubyPyInstance" do
      urllib2 = RubyPython.import 'urllib2'
      urllib2.Request.new('google.com').should be_a(RubyPython::PyAPI::RubyPyInstance)
    end
  end

end
