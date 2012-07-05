require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants

describe 'Callbacks' do
  {
    'procs' => AProc,
    'methods' => AMethod,
  }.each do |rb_type, rb_object|
    it "accepts #{rb_type} as functions" do
      [
        [2, 2],
        ["a", "Word"],
        [ [1, 2], [3, 4] ]
      ].each do |args|
        @objects.apply_callback(rb_object, args).should == rb_object.call(*args)
      end
    end
  end

  [
    ["an int", AnInt],
    ["a float", AFloat],
    ["a string", AString],
    ["a string with nulls", AStringWithNULLs],
    ["an array", AnArray],
    ["an array", AnArray],
    ["a hash", AConvertedHash],
    ["true", true],
    ["false", false],
    ["nil", nil]
  ].each do |rb_type, rb_value|
    it "is able to return #{rb_type}" do
      callback = Proc.new do 
        rb_value
      end

      @objects.apply_callback(callback, []).should == rb_value
    end
  end

  it "is able to be stored by python variables" do
    mockObject = @objects.RubyPythonMockObject.new
    mockObject.callback = AProc
  end

  it "is callable as a python instance variable" do
    mockObject = @objects.RubyPythonMockObject.new
    mockObject.callback = AProc
    mockObject.callback(2, 2).rubify.should == 4
  end

end
