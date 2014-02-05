# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe RubyPython::RubyPyProxy do
  before do
    @a = RubyPython::PyObject.new "a"
    @b = RubyPython::PyObject.new "b"
    @builtin = RubyPython.import("__builtin__").pObject
    @string = RubyPython.import("string").pObject

    @two = described_class.new 2
    @six = described_class.new 6

    @sys = RubyPython.import 'sys'
    @sys.path.append RPTest::Helpers
    @objects = RubyPython.import 'objects'
  end

  describe "#new" do
    it "accepts a PyObject instance" do
      rbPyObject = RubyPython::PyObject.new RPTest::AString
      expect {
        described_class.new rbPyObject
      }.not_to raise_exception
    end

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

      it "converts #{type} to wrapped pObject" do
        expect(described_class.new(input).pObject.rubify).to eq output
      end
    end
  end

  describe "#rubify" do
    [
      ["a string", RPTest::AString],
      ["an int", RPTest::AnInt],
      ["a float", RPTest::AFloat],
      ["an array", RPTest::AnArray],
      ["a symbol", RPTest::ASym],
      ["a hash", RPTest::AHash]
    ].each do |title, obj|
      it "faithfully unwraps #{title}" do
        pyObject = RubyPython::PyObject.new obj
        proxy = described_class.new pyObject
        expect(proxy.rubify).to eq pyObject.rubify
      end
    end
  end

  describe "#inspect" do
    it "returns 'repr' of wrapped object" do
      expect(@six.inspect).to eq '6'
    end

    it "gracefully handles the lack of a defined __repr__" do
      expect {
        @objects.RubyPythonMockObject.inspect
      }.not_to raise_exception
    end

    it "always tries the 'repr' function if __repr__ produces an error" do
      expect(RubyPython::PyMain.list.inspect).to eq run_python_command('print repr(list)').chomp
    end
  end

  describe "#to_s" do
    it "returns 'str' of wrapped object" do
      expect(@six.to_s).to eq '6'
    end

    it "gracefully handles the lack of a defined __str__" do
      expect {
        @objects.RubyPythonMockObject.to_s
      }.not_to raise_exception
    end

    it "always tries the 'str' function if __repr__ produces an error" do
      expect(RubyPython::PyMain.list.to_s).to eq run_python_command('print str(list)').chomp
    end
  end

  describe "#to_a" do
    it "converts a list to an array of its entries" do
      list = @objects.a_list
      expect(list.to_a).to \
        eq RPTest::AnArray.map { |x| described_class.new(x) }
    end

    it "converts a tuple to an array of its entries" do
      tuple = @objects.a_tuple
      expect(tuple.to_a).to \
        eq RPTest::AnArray.map { |x| described_class.new(x) }
    end

    it "converts a dict to an array of keys" do
      dict = @objects.a_dict
      expect(dict.to_a.sort).to \
        eq RPTest::AConvertedHash.keys.map { |x|
          described_class.new(x)
      }.sort
    end
  end

  describe "#respond_to?" do
    it "returns true given getters" do
      expect(@objects).to respond_to(:RubyPythonMockObject)
    end

    it "returns false given undefined methods" do
      expect(@objects).to_not respond_to(:undefined_attr)
    end

    it "returns true given any setter" do
      expect(@objects).to respond_to(:any_variable=)
    end

    it "returns true given methods on RubyPyProxy instance" do
      expect(@objects).to respond_to(:inspect)
    end
  end

  describe "method delegation" do
    it "refers method calls to wrapped objects" do
      aProxy = described_class.new(@a)
      bProxy = described_class.new(@b)
      expect(aProxy.__add__(bProxy).rubify).to eq (@a.rubify + @b.rubify)
    end

    it "raises NoMethodError when method is undefined" do
      aProxy = described_class.new @a
      expect {
        aProxy.wat
      }.to raise_exception NoMethodError
    end

    it "raises NoMethodError when boolean method is undefined" do
      aProxy = described_class.new @a
      expect {
        aProxy.wat?
      }.to raise_exception NoMethodError
    end

    it "allows methods to be called with no arguments" do
      builtinProxy = described_class.new @builtin
      rbStrClass = builtinProxy.str
      expect(rbStrClass.new.rubify).to eq String.new
    end

    it "fetches attributes when method name is an attribute" do
      pyLetters = @string.getAttr "ascii_letters"
      stringProxy = described_class.new @string
      expect(stringProxy.ascii_letters.rubify).to eq pyLetters.rubify
    end

    it "sets attribute if method call is a setter" do
      stringProxy = described_class.new @string
      stringProxy.letters = RPTest::AString
      expect(stringProxy.letters.rubify).to eq RPTest::AString
    end

    it "creates nonexistent attirubte if method call is a setter" do
      stringProxy = described_class.new @string
      stringProxy.nonExistent = 1
      expect(stringProxy.nonExistent.rubify).to eq 1
    end

    it "returns a class as a RubyPyClass" do
      urllib2 = RubyPython.import('urllib2')
      expect(urllib2.Request).to be_a(RubyPython::RubyPyClass)
    end

    it "passes named args via bang method" do
      expect(@objects.named_args!(:arg2 => 2, :arg1 => 1).rubify).to \
        eq [ 4, 2 ]
    end

    it "passes through keyword arguments via bang method" do
      builtinProxy = described_class.new @builtin
      args = [ { 'dict' => 'val' }, { :keyword => true } ]
      expect(builtinProxy.dict!(*args).rubify).to \
        eq({ 'dict' => 'val', 'keyword' => true })
    end
  end

  describe "when used with an operator" do
    [
      '+', '-', '/', '*', '&', '^', '%', '**', '>>', '<<', '<=>', '|'
    ].each do |op|
      it "delegates #{op}" do
        expect(@six.__send__(op, @two.rubify)).to eq 6.__send__(op, 2)
      end
    end

    [
      '~', '-@', '+@'
    ].each do |op|
      it "delegates #{op}" do
        expect(@six.__send__(op).rubify).to eq 6.__send__(op)
      end
    end

    ['==', '<', '>', '<=', '>='].each do |op|
      it "delegates #{op}" do
        expect(@six.__send__(op, @two)).to eq 6.__send__(op, 2)
      end
    end

    describe "#equal?" do
      it "is true given proxies representing the same object" do
        obj1 = @objects.RubyPythonMockObject
        obj2 = @objects.RubyPythonMockObject
        expect(obj1).to equal(obj2)
      end

      it "is false given objects which are different" do
        expect(@two).to_not equal(@six)
      end
    end

    it "allows list indexing" do
      array = described_class.new(RPTest::AnArray)
      expect(array[1].rubify).to eq RPTest::AnArray[1]
    end

    it "allows dict access" do
      dict = described_class.new(RPTest::AHash)
      key = RPTest::AConvertedHash.keys[0]
      expect(dict[key].rubify).to eq RPTest::AConvertedHash[key]
    end

    it "allows list index assignment" do
      array = described_class.new(RPTest::AnArray)
      val = RPTest::AString*2
      array[1] = val
      expect(array[1].rubify).to eq val
    end

    it "allows dict value modification" do
      dict = described_class.new(RPTest::AHash)
      key = RPTest::AConvertedHash.keys[0]
      val = RPTest::AString*2
      dict[key] = val
      expect(dict[key].rubify).to eq val
    end

    it "allows creation of new dict key-val pair" do
      dict = described_class.new(RPTest::AHash)
      key = RPTest::AString*2
      dict[key] = RPTest::AString
      expect(dict[key].rubify).to eq RPTest::AString
    end

    it "allows membership tests with include?" do
      list = described_class.new(RPTest::AnArray)
      expect(list.include?(RPTest::AnArray[0])).to eq true
    end
  end

  it "delegates object equality" do
    urllib_a = RubyPython.import('urllib')
    urllib_b = RubyPython.import('urllib')
    expect(urllib_a).to eq urllib_b
  end
end
