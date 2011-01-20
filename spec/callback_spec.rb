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

end
