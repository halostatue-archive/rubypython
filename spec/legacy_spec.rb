require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants

describe 'RubyPython Legacy Mode Module' do

  before do
    RubyPython.start
    sys = RubyPython.import 'sys'
    path = sys.path
    path.push './spec/python_helpers'
    sys.path = path
    @objects = RubyPython.import 'objects'
  end

  after do
    RubyPython.stop
  end

  before :all do
    require 'rubypython/legacy'
  end

  after :all do
    RubyPython::LegacyMode.teardown_legacy
  end

  describe "when required" do
    it "should enable legacy mode" do
      RubyPython.legacy_mode.should == true
    end

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
      it "should implicitly convert #{py_type} to #{rb_type}" do
        @objects.__send__(py_type.sub(' ', '_')).should == output
      end
    end

    [
      ["proc", AProc],
      ["method", AMethod]
    ].each do |rb_type, rb_obj| 
      it "should raise an exception if a #{rb_type} callback is supplied" do
        lambda do
          @objects.apply_callback(rb_obj, [1, 1])
        end.should raise_exception(RubyPython::Conversion::UnsupportedConversion)
      end
    end
  end

end
