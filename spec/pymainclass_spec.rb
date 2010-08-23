require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyPython::PyMainClass do
  include TestConstants
  include RubyPythonStartStop

  subject { RubyPython::PyMain }

  it "should delegate to builtins" do
    subject.float(AnInt).rubify.should == AnInt.to_f
  end

  it "should handle block syntax" do
    subject.float(AnInt) {|f| f.rubify*2}.should == (AnInt.to_f * 2)
  end

  describe "#eval" do
    specify { subject.eval('1+1').rubify.should == 2 }
  end

end
