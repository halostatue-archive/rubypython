# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe RubyPython::PyObject do
  before do
    @string = RubyPython.import('string').pObject
    @urllib2 = RubyPython.import('urllib2').pObject
    @builtin = RubyPython.import("__builtin__")
    sys = RubyPython.import 'sys'
    sys.path.append RPTest::Helpers
    @objects = RubyPython.import('objects')
  end

  describe ".new" do
    [
      ["a string", RPTest::AString],
      ["an int", RPTest::AnInt],
      ["a float", RPTest::AFloat],
      ["an array", RPTest::AnArray],
      ["a symbol", RPTest::ASym],
      ["a hash", RPTest::AHash]
    ].each do |title, obj|
      it "wraps #{title}" do
        expect {
          described_class.new(obj)
        }.not_to raise_exception
      end
    end

    [
      "a string",
      "an int",
      "a list",
      "a dict",
      "a tuple"
    ].each do |title|
      it "takes #{title} from a Python pointer" do
        expect {
          py_obj = @objects.__send__(title.gsub(' ','_')).pObject.pointer
          described_class.new(py_obj)
        }.not_to raise_exception
      end
    end
  end

  describe "#rubify" do
    [
      ["a string", RPTest::AString],
      ["an int", RPTest::AnInt],
      ["a float", RPTest::AFloat],
      ["an array", RPTest::AnArray],
      ["a symbol", RPTest::ASym, RPTest::ASym.to_s],
      ["a hash", RPTest::AHash, RPTest::AConvertedHash]
    ].each do |arr|
      type, input, output = arr
      output ||= input

      it "faithfully unwraps #{type}" do
        expect(described_class.new(input).rubify).to eq output
      end
    end
  end

  describe "#hasAttr" do
    it "returns true when object has the requested attribute" do
      expect(@string.hasAttr("ascii_letters")).to eq true
    end

    it "returns false when object is missing the requested attribute" do
      expect(@string.hasAttr("nonExistentThing")).to eq false
    end
  end

  describe "#getAttr" do
    it "fetches requested object attribute" do
      ascii_letters = @string.getAttr "ascii_letters"
      expect(ascii_letters.rubify).to \
        eq "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    end

    it "returns a PyObject instance" do
      ascii_letters = @string.getAttr "ascii_letters"
      expect(ascii_letters).to be_instance_of described_class
    end
  end

  describe "#setAttr" do
    it "modifies the specified attribute of the object" do
      pyNewLetters = described_class.new "RbPy"
      @string.setAttr "ascii_letters", pyNewLetters
      expect(@string.getAttr("ascii_letters").rubify).to \
        eq pyNewLetters.rubify
    end

    it "creates the requested attribute if it doesn't exist" do
      pyNewString = described_class.new "python"
      @string.setAttr "ruby", pyNewString
      expect(@string.getAttr("ruby").rubify).to eq pyNewString.rubify
    end
  end

  describe "#cmp" do
    before do
      @less = described_class.new 5
      @greater = described_class.new 10
      @less_dup = described_class.new 5
    end

    it "returns 0 when objects are equal" do
      expect(@less.cmp(@less_dup)).to eq 0
    end

    it "changes sign under interchange of arguments" do
      expect(@less.cmp(@greater)).to eq -@greater.cmp(@less)
    end

    it "returns -1 when first object is less than the second" do
      expect(@less.cmp(@greater)).to eq -1
    end

    it "returns 1 when first object is greater than the second" do
      expect(@greater.cmp(@less)).to eq 1
    end
  end

  describe "#callObject" do
    # Expand coverage types
    it "executes the wrapped object with supplied arguments" do
      arg = described_class.new RPTest::AnInt
      argt = described_class.buildArgTuple arg

      builtin = @builtin.pObject
      stringClass = builtin.getAttr "str"
      expect(stringClass.callObject(argt).rubify).to eq RPTest::AnInt.to_s
    end
  end

  describe "#function_or_method?" do
    it "returns true given a method" do
      mockObjClass = @objects.RubyPythonMockObject.pObject
      expect(mockObjClass.getAttr('square_elements')).to \
        be_a_function_or_method
    end

    it "returns be true given a function" do
      expect(@objects.pObject.getAttr('identity')).to \
        be_a_function_or_method
    end

    it "returns true given a builtin function" do
      any = @builtin.pObject.getAttr('any')
      expect(any).to be_a_function_or_method
    end

    it "returns false given a class" do
      expect(@objects.RubyPythonMockObject.pObject).not_to \
        be_a_function_or_method
    end
  end

  describe "#class?" do
    it "returns true if wrapped object is an old style class" do
      expect(@objects.RubyPythonMockObject.pObject).to be_a_class
    end

    it "returns true if wrapped object is an new style class" do
      expect(@objects.NewStyleClass.pObject).to be_a_class
    end

    it "returns true if wrapped object is a builtin class" do
      strClass = @builtin.pObject.getAttr('str')
      expect(strClass).to be_a_class
    end

    it "returns false given an object instance" do
      expect(@objects.RubyPythonMockObject.new.pObject).not_to be_a_class
    end
  end

  describe "#callable?" do
    it "returns true given a method" do
      mockObjClass = @objects.RubyPythonMockObject.pObject
      expect(mockObjClass.getAttr('square_elements')).to be_callable
    end

    it "returns true given a function" do
      expect(@objects.pObject.getAttr('identity')).to be_callable
    end

    it "returns true given a builtin function" do
      any = @builtin.pObject.getAttr('any')
      expect(any).to be_callable
    end

    it "returns true given a class" do
      expect(@objects.RubyPythonMockObject.pObject).to be_callable
    end

    it "returns false given a non-callable instance" do
      expect(@objects.RubyPythonMockObject.new.pObject).not_to be_callable
    end

    it "returns false given a non-callable value" do
      expect(described_class.new(6)).not_to be_callable
    end
  end
end
