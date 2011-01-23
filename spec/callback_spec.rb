require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'Callbacks' do
  include TestConstants
  
  before do
    RubyPython.start
    @sys = RubyPython.import 'sys'
    @sys.path.append './spec/python_helpers'
    @objects = RubyPython.import 'objects'
  end

  after do
    RubyPython.start
  end

  [
    [ 'procs', AProc ],
    [ 'methods', AMethod]
  ].each do |rb_type, rb_object|
    it "should accept #{rb_type} as functions" do
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
    ["an array", AnArray],
    ["an array", AnArray],
    ["a hash", AConvertedHash],
    ["true", true],
    ["false", false],
    ["nil", nil]
  ].each do |rb_type, rb_value|
    it "should allow callbacks to return #{rb_type}" do
      callback = Proc.new do 
        rb_value
      end

      @objects.apply_callback(callback, []).should == rb_value
    end
  end

end
