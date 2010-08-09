require File.dirname(__FILE__) + '/spec_helper.rb'

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
