require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyPython::PythonError do
  before do
    RubyPython.start
  end

  after do
    RubyPython.stop
  end

  describe "#error?" do
    it "should return false when no error has occured" do
      described_class.error?.should be_false
    end

    it "should return true when an error has occured" do
      RubyPython::Python.PyImport_ImportModule("wat")
      described_class.error?.should be_true
    end
  end

  describe "#clear" do
    it "should reset the Python error flag" do
      RubyPython::Python.PyImport_ImportModule("wat")
      described_class.clear
      described_class.error?.should be_false
    end

    it "should not barf when there is no error" do
      lambda {described_class.clear}.should_not raise_exception
    end
  end


  describe "#fetch" do
    it "should make availible Python error type" do
      RubyPython::Python.PyImport_ImportModule("wat")
      rbType, rbValue, rbTraceback = described_class.fetch
      rbType.getAttr("__name__").rubify.should == "ImportError"
    end
  end

end

