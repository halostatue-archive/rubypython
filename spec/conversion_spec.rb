require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants

describe RubyPython::Conversion do
  subject { RubyPython::Conversion }

  context "when converting from Python to Ruby" do
    [
      ["an int", "an int", AnInt],
      ["a float", "a float", AFloat],
      ["a string", "a string", AString],
      ["a string_with_nulls", "a string_with_nulls", AStringWithNULLs],
      ["a list", "an array", AnArray],
      ["a tuple", "a tuple", ATuple],
      ["a dict", "a hash", AConvertedHash],
      ["python True", "true", true],
      ["python False", "false", false],
      ["python None", "nil", nil]
    ].each do |py_type, rb_type, output|
      it "should convert #{py_type} to #{rb_type}" do
        py_object_ptr = @objects.__send__(py_type.sub(' ', '_')).pObject.pointer
        obj = subject.ptorObject(py_object_ptr)
        obj.should == output
        obj.class.should == output.class
      end
    end

    it "should return an FFI::Pointer when it cannot convert" do
      unconvertable = @objects.RubyPythonMockObject.pObject.pointer
      subject.ptorObject(unconvertable).should be_a_kind_of(FFI::Pointer)
    end
  end

  context "when converting Ruby to Python" do
    [
      ["an int", "an int", AnInt],
      ["a float", "a float", AFloat],
      ["a string", "a string", AString],
      ["a string_with_nulls", "a string_with_nulls", AStringWithNULLs],
      ["a string", "a symbol", ASym],
      ["a list", "an array", AnArray],
      ["a tuple", "a tuple", ATuple ],
      ["a dict", "a hash", AConvertedHash],
      ["python True", "true", true],
      ["python False", "false", false],
      ["python None", "nil", nil],
      ["a function", "a proc", AProc, true]
    ].each do |py_type, rb_type, input, no_compare|
      it "should convert #{rb_type} to #{py_type}" do
        py_object_ptr = subject.rtopObject(input)
        unless no_compare
          output = @objects.__send__(rb_type.sub(' ', '_')).pObject.pointer
          RubyPython::Python.PyObject_Compare(py_object_ptr, output).should == 0
        end
      end
    end

    it "should raise an exception when it cannot convert" do
      lambda { subject.rtopObject(Class) }.should raise_exception(subject::UnsupportedConversion)
    end

    it "should convert a tuple correctly" do
      @basics.expects_tuple(AnArray).should == false
      @basics.expects_tuple(RubyPython::Tuple.tuple(AnArray)).should == true
    end
  end
end
