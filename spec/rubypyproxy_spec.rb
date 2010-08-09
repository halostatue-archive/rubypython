require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyPython::RubyPyProxy do
  include TestConstants

  before do
    RubyPython.start
    @a = RubyPython::PyObject.new "a"
    @b = RubyPython::PyObject.new "b"
    @builtin = RubyPython.import("__builtin__").pObject
    @string = RubyPython.import("string").pObject

    @two = 2
    @six = 6
  end

  after do
    RubyPython.stop
  end

  describe "#new" do
    it "should accept a PyObject instance" do
      rbPyObject = RubyPython::PyObject.new AString
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
        pyObject = RubyPython::PyObject.new obj
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
      urllib2.Request.should be_a(RubyPython::RubyPyClass)
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
    urllib_a = RubyPython.import('urllib')
    urllib_b = RubyPython.import('urllib')
    urllib_a.should == urllib_b
  end

end
