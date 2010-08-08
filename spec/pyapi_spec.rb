require File.dirname(__FILE__) + '/spec_helper.rb'

module TestConstants
    @aString = "STRING"
    @anInt = 1
    @aChar = 'a'
    @aFloat = 1.0
    @anArray = [@anInt, @aChar, @aFloat, @aString]
    @aHash = {
      @anInt => @anInt,
      @aChar.to_sym => @aChar,
      @aSym => @aFloat,
      @aString => @aString
    }

end

describe RubyPython::PyAPI, "when starting/stopping interpreter" do
  
  it "start and stop only once" do
    RubyPython::PyAPI.start.should be_true
    RubyPython::PyAPI.start.should be_false
    RubyPython::PyAPI.stop.should be_true
    RubyPython::PyAPI.stop.should be_false
  end
  
end

describe RubyPython::PyAPI::PyObject do
  include TestConstants
  before do
    RubyPython::PyAPI.start
  end

  after do
    RubyPython::PyAPI.stop
  end

  describe "#new" do

    [
      ["a string", @aString],
      ["an int", @anInt],
      ["a float", @aFloat],
      ["an array", @anArray],
      ["a symbol", @aSym],
      ["a hash", @aHash]
    ].each do |title, obj|
      it "should wrap #{title}" do
        described_class.new(obj).should be_instance_of(described_class)
      end
    end

  end

end
