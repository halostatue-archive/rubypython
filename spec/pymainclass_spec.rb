require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants

describe RubyPython::PyMainClass do
  subject { RubyPython::PyMain }

  it "should delegate to builtins" do
    subject.float(AnInt).rubify.should == AnInt.to_f
  end

  it "should handle block syntax" do
    subject.float(AnInt) {|f| f.rubify*2}.should == (AnInt.to_f * 2)
  end

  it "should allow attribute access" do
    subject.main.__name__.rubify.should == '__main__'
  end

  it "should allow global variable setting" do
    subject.x = 2
    subject.x.rubify.should == 2
  end
end
