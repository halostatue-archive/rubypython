require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyPython::PythonError do
  def cause_error
    RubyPython::Python.PyImport_ImportModule("wat")
  end

  describe "#error?" do
    it "should return false when no error has occured" do
      described_class.error?.should be_false
    end

    it "should return true when an error has occured" do
      cause_error
      described_class.error?.should be_true
    end
  end

  describe "#clear" do
    it "should reset the Python error flag" do
      cause_error
      described_class.clear
      described_class.error?.should be_false
    end

    it "should not barf when there is no error" do
      lambda {described_class.clear}.should_not raise_exception
    end
  end

  describe "#fetch" do
    it "should make availible Python error type" do
      cause_error
      rbType, rbValue, rbTraceback = described_class.fetch
      rbType.getAttr("__name__").rubify.should == "ImportError"
    end
  end

  describe ".last_traceback" do
    it "should make availble the Python traceback of the last error" do
      traceback = RubyPython.import 'traceback'
      errors = RubyPython.import 'errors'
      begin
        errors.nested_error
      rescue RubyPython::PythonError => exc
        tb = exc.traceback
        list = traceback.format_tb(tb)
        list.rubify[0].should =~ /1 \/ 0/
      end
    end
  end
end
