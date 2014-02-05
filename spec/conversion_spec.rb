# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe RubyPython::Conversion do
  subject { described_class }

  context "when converting from Python to Ruby" do
    [
      ["an int", "an int", RPTest::AnInt],
      ["a float", "a float", RPTest::AFloat],
      ["a string", "a string", RPTest::AString],
      ["a string_with_nulls", "a string_with_nulls", RPTest::AStringWithNULLs],
      ["a list", "an array", RPTest::AnArray],
      ["a tuple", "a tuple", RPTest::ATuple],
      ["a dict", "a hash", RPTest::AConvertedHash],
      ["python True", "true", true],
      ["python False", "false", false],
      ["python None", "nil", nil]
    ].each do |py_type, rb_type, output|
      it "converts from #{py_type} to #{rb_type}" do
        py_object_ptr =
          @objects.__send__(py_type.sub(' ', '_')).pObject.pointer
        object = subject.ptorObject(py_object_ptr)
        expect(object).to eq(output)
        expect(object).to be_an_instance_of(output.class)
      end
    end

    it "returns an FFI::Pointer when it cannot convert" do
      unconvertable = @objects.RubyPythonMockObject.pObject.pointer
      expect(subject.ptorObject(unconvertable)).to \
        be_a_kind_of FFI::Pointer
    end
  end

  context "when converting Ruby to Python" do
    [
      ["an int", "an int", RPTest::AnInt],
      ["a float", "a float", RPTest::AFloat],
      ["a string", "a string", RPTest::AString],
      ["a string_with_nulls", "a string_with_nulls", RPTest::AStringWithNULLs],
      ["a string", "a symbol", RPTest::ASym],
      ["a list", "an array", RPTest::AnArray],
      ["a tuple", "a tuple", RPTest::ATuple ],
      ["a dict", "a hash", RPTest::AConvertedHash],
      ["python True", "true", true],
      ["python False", "false", false],
      ["python None", "nil", nil],
      ["a function", "a proc", RPTest::AProc, true]
    ].each do |py_type, rb_type, input, no_compare|
      it "converts from #{rb_type} to #{py_type}" do
        py_object_ptr = subject.rtopObject(input)
        unless no_compare
          output = @objects.__send__(rb_type.sub(' ', '_')).pObject.pointer
          result =
            RubyPython::Python.PyObject_Compare(py_object_ptr, output)
          expect(result).to eq 0
        end
      end
    end

    it "raises an exception when it cannot convert" do
      expect {
        subject.rtopObject(Class)
      }.to raise_error(subject::UnsupportedConversion)
    end

    it "converts a tuple correctly" do
      array_tuple = RubyPython::Tuple(RPTest::AnArray)
      expect(@basics.expects_tuple(RPTest::AnArray)).to eq false
      expect(@basics.expects_tuple(array_tuple)).to eq true
    end
  end
end
