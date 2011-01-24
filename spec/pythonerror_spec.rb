require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyPython::PythonError do

  before do
    RubyPython.start
  end
  
  after do
    RubyPython.start
  end

  def cause_error
    RubyPython::Python.PyImport_ImportModule("wat")
  end

  describe "#error?" do
    it "is false when no error has occured" do
      described_class.error?.should be_false
    end

    it "is true when an error has occured" do
      cause_error
      described_class.error?.should be_true
    end
  end

  describe "#clear" do
    it "resets the Python error flag" do
      cause_error
      described_class.clear
      described_class.error?.should be_false
    end

    it "doesn't barf when there is no error" do
      lambda {described_class.clear}.should_not raise_exception
    end
  end


  describe "#fetch" do
    it "makes availible Python error type" do
      cause_error
      rbType, rbValue, rbTraceback = described_class.fetch
      rbType.getAttr("__name__").rubify.should == "ImportError"
    end
  end

end

