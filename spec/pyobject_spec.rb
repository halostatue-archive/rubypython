require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyPython::PyObject do
  include TestConstants

  before do
    RubyPython.start
  end
  
  after do
    RubyPython.start
  end

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

      it "wraps #{title}" do
        lambda { described_class.new(obj) }.should_not raise_exception
      end
    end

    [
      "a string",
      "an int",
      "a list",
      "a dict",
      "a tuple"
    ].each do |type|
      it "accepts a Python pointer to a #{type}" do
        lambda do
          py_obj = @objects.__send__(type.gsub(' ','_')).pObject.pointer
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

      it "faithfully unwraps #{type}" do
        described_class.new(input).rubify.should == output
      end

    end

  end #rubify

  describe "#hasAttr" do
    it "is true when wrapped object has the requested attribute" do
      @string.hasAttr("ascii_letters").should be_true
    end

    it "is false when wrapped object does not have the requested attribute" do
      @string.hasAttr("nonExistentThing").should be_false
    end
  end

  describe "#getAttr" do
    it "fetchs a pointer to the requested object attribute" do 
      ascii_letters = @string.getAttr "ascii_letters"
      ascii_letters.rubify.should == "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    end

    it "returns a PyObject instance" do
      ascii_letters = @string.getAttr "ascii_letters"
      ascii_letters.should be_kind_of(described_class)
    end
  end

  describe "#setAttr" do 
    it "modifies the specified attribute of the object" do
      pyNewLetters = described_class.new "RbPy"
      @string.setAttr "ascii_letters", pyNewLetters
      @string.getAttr("ascii_letters").rubify.should == pyNewLetters.rubify
    end

    it "creates the requested attribute if it doesn't exist" do 
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

    it "returns 0 when objects are equal" do
      @less.cmp(@less_dup).should == 0
    end

    it "changes sign under interchange of arguments" do 
      @less.cmp(@greater).should == -@greater.cmp(@less)
    end

    it "returns -1 when first object is less than the second" do
      @less.cmp(@greater).should == -1
    end
    
    it "returns 1 when first object is greater than the second" do
      @greater.cmp(@less).should == 1
    end
  end

  describe "#makeTuple" do
    it "wraps single arguments in a tuple" do
      arg = described_class.new AString
      described_class.makeTuple(arg).rubify.should == [AString]
    end

    it "turns a Python list into a tuple" do
      arg = @objects.a_list.pObject
      converted = described_class.makeTuple(arg)
      converted.rubify.should == AnArray
    end

    it "returns the given argument if it is a tuple" do
      arg = @objects.a_tuple.pObject
      converted = described_class.makeTuple(arg)
      converted.pointer.address.should == arg.pointer.address
    end

  end

  describe "#callObject" do
    #Expand coverage types
    it "executes wrapped object with supplied arguments" do
      arg = described_class.new AnInt
      argt = described_class.buildArgTuple arg

      builtin = @builtin.pObject
      stringClass = builtin.getAttr "str"
      stringClass.callObject(argt).rubify.should == AnInt.to_s
    end
  end

  describe "#newList" do
    it "wraps supplied args in a Python list" do
      args = AnArray.map do |obj|
        described_class.new obj
      end
      described_class.newList(*args).rubify.should == AnArray
    end
  end

  describe "#function_or_method?" do

    it "is true for a method" do
      mockObjClass = @objects.RubyPythonMockObject.pObject
      mockObjClass.getAttr('square_elements').should be_a_function_or_method
    end

    it "is true for a function" do
      @objects.pObject.getAttr('identity').should be_a_function_or_method
    end

    it "is true for a builtin function" do
      any = @builtin.pObject.getAttr('any')
      any.should be_a_function_or_method
    end

    it "is false for a class" do
      @objects.RubyPythonMockObject.pObject.should_not be_a_function_or_method
    end

  end

  describe "#class?" do

    it "is true if wrapped object is an old style class" do
      @objects.RubyPythonMockObject.pObject.should be_a_class
    end

    it "is true if wrapped object is an new style class" do
      @objects.NewStyleClass.pObject.should be_a_class
    end

    it "is true if wrapped object is a builtin class" do
      strClass = @builtin.pObject.getAttr('str')
      strClass.should be_a_class
    end

    it "is false for an object instance" do
      @objects.RubyPythonMockObject.new.pObject.should_not be_a_class
    end

  end

  describe "#callable?" do

    it "is true for a method" do
      mockObjClass = @objects.RubyPythonMockObject.pObject
      mockObjClass.getAttr('square_elements').should be_callable
    end

    it "is true for a function" do
      @objects.pObject.getAttr('identity').should be_callable
    end

    it "is true for a builtin function" do
      any = @builtin.pObject.getAttr('any')
      any.should be_callable
    end

    it "is true for a class" do
      @objects.RubyPythonMockObject.pObject.should be_callable
    end

    it "is false for a non-callable instance" do
      @objects.RubyPythonMockObject.new.pObject.should_not be_callable
    end

    specify { described_class.new(6).should_not be_callable }

  end

  describe ".convert" do

    it "does not modify PyObjects passed to it" do
      args = AnArray.map { |x| described_class.new(x) }
      described_class.convert(*args).should == args
    end

    it "pulls PyObjects out of RubyPyProxy instances" do
      args = @objects.an_array.to_a
      described_class.convert(*args).should == args.map {|x| x.pObject}
    end

    it "creates new PyObject instances of simple Ruby types" do
      described_class.convert(*AnArray).each do |x|
        x.should be_a_kind_of described_class
      end
    end

  end

end

