require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants
describe RubyPython::RubyPyProxy do
  before do
    @a = RubyPython::PyObject.new "a"
    @b = RubyPython::PyObject.new "b"
    @builtin = RubyPython.import("__builtin__").pObject
    @string = RubyPython.import("string").pObject

    @two = described_class.new 2
    @six = described_class.new 6

    @sys = RubyPython.import 'sys'
    @sys.path.append './spec/python_helpers'
    @objects = RubyPython.import 'objects'
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

  describe "#inspect" do
    it "should return 'repr' of wrapped object" do
      @six.inspect.should == '6'
    end

    it "should gracefully handle lack of defined __repr__" do
      lambda { @objects.RubyPythonMockObject.inspect }.should_not raise_exception
    end

    it "always tries the 'repr' function if __repr__ produces an error" do
      RubyPython::PyMain.list.inspect.should == run_python_command('print repr(list)').chomp
    end
  end

  describe "#to_s" do
    it "should return 'str' of wrapped object" do
      @six.to_s.should == '6'
    end

    it "should gracefully handle lack of defined __str__" do
      lambda { @objects.RubyPythonMockObject.to_s }.should_not raise_exception
    end

    it "always tries the 'str' function if __repr__ produces an error" do
      RubyPython::PyMain.list.to_s.should == run_python_command('print str(list)').chomp
    end
  end

  describe "#to_a" do
    it "should convert a list to an array of its entries" do
      list = @objects.a_list
      list.to_a.should == AnArray.map { |x| described_class.new(x) }
    end

    it "should convert a tuple to an array of its entries" do
      tuple = @objects.a_tuple
      tuple.to_a.should == AnArray.map { |x| described_class.new(x) }
    end

    it "should convert a dict to an array of keys" do
      dict = @objects.a_dict
      dict.to_a.sort.should == AConvertedHash.keys.map {|x| described_class.new(x)}.sort
    end
  end

  describe "#respond_to?" do
    it "should return true given getters" do
      @objects.should respond_to(:RubyPythonMockObject)
    end

    it "should return false given undefined methods" do
      @objects.should_not respond_to(:undefined_attr)
    end

    it "should return true given any setter" do
      @objects.should respond_to(:any_variable=)
    end

    it "should return true given methods on RubyPyProxy instance" do
      @objects.should respond_to(:inspect)
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
      lambda {aProxy.wat}.should raise_exception(NoMethodError)
    end

    it "raises NoMethodError when boolean method is undefined" do
      aProxy = described_class.new @a
      lambda { aProxy.wat? }.should raise_exception(NoMethodError)
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

    it "should create nonexistent attirubte if method call is a setter" do
      stringProxy = described_class.new @string
      stringProxy.nonExistent = 1
      stringProxy.nonExistent.rubify.should == 1
    end

    it "should return a class as a RubyPyClass" do
      urllib2 = RubyPython.import('urllib2')
      urllib2.Request.should be_a(RubyPython::RubyPyClass)
    end

    it "should pass named args via bang method" do
      @objects.named_args!(:arg2 => 2, :arg1 => 1).rubify.should == [4,2]
    end

    it "should pass through keyword arguments via bang method" do
      builtinProxy = described_class.new @builtin
      builtinProxy.dict!({'dict'=>'val'}, :keyword=>true).rubify.should == {
        'dict' => 'val',
        'keyword' => true
      }
    end
  end

  describe "when used with an operator" do
    [
      '+', '-', '/', '*', '&', '^', '%', '**',
      '>>', '<<', '<=>', '|'
    ].each do |op|
      it "should delegate #{op}" do
        @six.__send__(op, @two).rubify.should == 6.__send__(op, 2)
      end
    end

    [
      '~', '-@', '+@'
    ].each do |op|
      it "should delegate #{op}" do
        @six.__send__(op).rubify.should == 6.__send__(op)
      end
    end

    ['==', '<', '>', '<=', '>='].each do |op|
      it "should delegate #{op}" do
        @six.__send__(op, @two).should == 6.__send__(op, 2)
      end
    end

    describe "#equal?" do
      it "be true given proxies representing the same object" do
        obj1 = @objects.RubyPythonMockObject
        obj2 = @objects.RubyPythonMockObject
        obj1.should equal(obj2)
      end

      it "should be false given objects which are different" do
        @two.should_not equal(@six)
      end
    end

    it "should allow list indexing" do
      array = described_class.new(AnArray)
      array[1].rubify.should == AnArray[1]
    end

    it "should allow dict access" do
      dict = described_class.new(AHash)
      key = AConvertedHash.keys[0]
      dict[key].rubify.should == AConvertedHash[key]
    end

    it "should allow list index assignment" do
      array = described_class.new(AnArray)
      val = AString*2
      array[1] = val
      array[1].rubify.should == val
    end

    it "should allow dict value modification" do
      dict = described_class.new(AHash)
      key = AConvertedHash.keys[0]
      val = AString*2
      dict[key] = val
      dict[key].rubify.should == val
    end

    it "should allow creation of new dict key-val pair" do
      dict = described_class.new(AHash)
      key = AString*2
      dict[key] = AString
      dict[key].rubify.should == AString
    end

    it "should allow membership tests with include?" do
      list = described_class.new(AnArray)
      list.include?(AnArray[0]).should be_true
    end
  end

  it "should delegate object equality" do
    urllib_a = RubyPython.import('urllib')
    urllib_b = RubyPython.import('urllib')
    urllib_a.should == urllib_b
  end
end
