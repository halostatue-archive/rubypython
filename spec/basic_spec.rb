require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants

describe "RubyPython Basics" do
  it "should work with cPickle" do
    cPickle = RubyPython.import("cPickle")
    string = cPickle.dumps("Testing RubyPython.")
    string.should_not be_a_kind_of String
    string.rubify.should be_a_kind_of String
  end
end
