require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyPython do
  before do
    RubyPython.start
  end

  after do
    RubyPython.stop
  end

  describe "#import" do
    it "should handle multiple imports" do
      lambda do
        RubyPython.import 'cPickle'
        RubyPython.import 'urllib'
      end.should_not raise_exception
    end

    it "should propagate Python errors" do
      lambda do
        RubyPython.import 'nonExistentModule'
      end.should raise_exception(RubyPython::PythonError)
    end
  end
end

describe PyMain do
  include TestConstants

  before do
    RubyPython.start
  end

  after do
    RubyPython.stop
  end

  it "should delegate to builtins" do
    PyMain.float(AnInt).rubify.should == AnInt.to_f
  end

  it "should handle block syntax" do
    PyMain.float(AnInt) {|f| f.rubify*2}.should == (AnInt.to_f * 2)
  end


end
