require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants
describe RubyPython::Conversion do
  include RubyPythonStartStop

  subject { RubyPython::Conversion }

  before do
    sys = RubyPython.import 'sys'
    sys.path.append './spec/python_helpers'
    @objects = RubyPython.import 'objects'
  end

  context "when converting from Python to Ruby" do
    [
      ["an int", "an int", AnInt],
      ["a float", "a float", AFloat],
      ["a string", "a string", AString],
      ["a list", "an array", AnArray],
      ["a tuple", "an array", AnArray],
      ["a dict", "a hash", AConvertedHash],
      ["python True", "true", true],
      ["python False", "false", false],
      ["python None", "nil", nil]
    ].each do |py_type, rb_type, output|
      it "should convert #{py_type} to #{rb_type}" do
        py_object_ptr = @objects.__send__(py_type.sub(' ', '_')).pObject.pointer
        subject.ptorObject(py_object_ptr).should == output
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
      ["a string", "a symbol", ASym],
      ["a list", "an array", AnArray],
      ["a dict", "a hash", AConvertedHash],
      ["python True", "true", true],
      ["python False", "false", false],
      ["python None", "nil", nil]
    ].each do |py_type, rb_type, input|

      it "should convert #{rb_type} to #{py_type}" do
        py_object_ptr = subject.rtopObject(input)
        output = @objects.__send__(rb_type.sub(' ', '_')).pObject.pointer
        RubyPython::Python.PyObject_Compare(py_object_ptr, output).should == 0
      end
    end

    it "should raise an exception when it cannot convert" do
      lambda { subject.rtopObject(Class) }.should raise_exception(subject::UnsupportedConversion)
    end

  end

end
