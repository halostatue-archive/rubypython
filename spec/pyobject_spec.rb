require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants

describe RubyPython::PyObject do
  before do
    @string = RubyPython.import('string').pObject
    @urllib2 = RubyPython.import('urllib2').pObject
    @builtin = RubyPython.import("__builtin__")
    sys = RubyPython.import 'sys'
    sys.path.append './spec/python_helpers/'
    @objects = RubyPython.import('objects')
  end

  describe ".new" do
    [
      ["a string", AString],
      ["an int", AnInt],
      ["a float", AFloat],
      ["an array", AnArray],
      ["a symbol", ASym],
      ["a hash", AHash]
    ].each do |title, obj|
      it "should wrap #{title}" do
        lambda { described_class.new(obj) }.should_not raise_exception
      end
    end

    [
      "a string",
      "an int",
      "a list",
      "a dict",
      "a tuple"
    ].each do |title|
      it "should take #{title} from a Python pointer" do
        lambda do
          py_obj = @objects.__send__(title.gsub(' ','_')).pObject.pointer
          described_class.new(py_obj)
        end.should_not raise_exception
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


  describe "#callObject" do
    #Expand coverage types
    it "should execute wrapped object with supplied arguments" do
      arg = described_class.new AnInt
      argt = described_class.buildArgTuple arg

      builtin = @builtin.pObject
      stringClass = builtin.getAttr "str"
      stringClass.callObject(argt).rubify.should == AnInt.to_s
    end
  end

  describe "#function_or_method?" do
    it "should be true given a method" do
      mockObjClass = @objects.RubyPythonMockObject.pObject
      mockObjClass.getAttr('square_elements').should be_a_function_or_method
    end

    it "should be true given a function" do
      @objects.pObject.getAttr('identity').should be_a_function_or_method
    end

    it "should return true given a builtin function" do
      any = @builtin.pObject.getAttr('any')
      any.should be_a_function_or_method
    end

    it "should return false given a class" do
      @objects.RubyPythonMockObject.pObject.should_not be_a_function_or_method
    end
  end

  describe "#class?" do
    it "should return true if wrapped object is an old style class" do
      @objects.RubyPythonMockObject.pObject.should be_a_class
    end

    it "should return true if wrapped object is an new style class" do
      @objects.NewStyleClass.pObject.should be_a_class
    end

    it "should return true if wrapped object is a builtin class" do
      strClass = @builtin.pObject.getAttr('str')
      strClass.should be_a_class
    end

    it "should return false given an object instance" do
      @objects.RubyPythonMockObject.new.pObject.should_not be_a_class
    end
  end

  describe "#callable?" do
    it "should be true given a method" do
      mockObjClass = @objects.RubyPythonMockObject.pObject
      mockObjClass.getAttr('square_elements').should be_callable
    end

    it "should be true given a function" do
      @objects.pObject.getAttr('identity').should be_callable
    end

    it "should return true given a builtin function" do
      any = @builtin.pObject.getAttr('any')
      any.should be_callable
    end

    it "should return true given a class" do
      @objects.RubyPythonMockObject.pObject.should be_callable
    end

    it "should return false given a non-callable instance" do
      @objects.RubyPythonMockObject.new.pObject.should_not be_callable
    end

    specify { described_class.new(6).should_not be_callable }

  end

  describe ".convert" do
    it "should not modify PyObjects passed to it" do
      args = AnArray.map { |x| described_class.new(x) }
      described_class.convert(*args).should == args
    end

    it "should pull PyObjects out of RubyPyProxy instances" do
      args = @objects.an_array.to_a
      described_class.convert(*args).should == args.map {|x| x.pObject}
    end

    it "should create new PyObject instances of simple Ruby types" do
      described_class.convert(*AnArray).each do |x|
        x.should be_a_kind_of described_class
      end
    end
  end
end
