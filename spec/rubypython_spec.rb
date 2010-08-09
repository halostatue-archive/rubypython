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

    it "should return a RubyPyModule" do
      RubyPython.import('urllib2').should be_a(RubyPython::PyAPI::RubyPyModule)
    end
  end

end

describe RubyPython, "#session" do

  it "should stop the interpreter when an error occurs" do
    begin
      RubyPython.session do
        raise "ERROR"
      end
    rescue
      RubyPython.stop.should be_false
    end
  end

  it "should start interpreter" do
    RubyPython.session do
      cPickle = RubyPython.import "cPickle"
      cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.").rubify.should == {"a"=>"n", [1, "2"]=>4}
    end

  end

end

describe PyMainClass do
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

