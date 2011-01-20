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

  it "procs should be accepted as functions" do
    [
      [2, 2],
      ["a", "Word"],
      [ [1, 2], [3, 4] ]
    ].each do |args|
      @objects.apply_callback(AProc, args).should == AProc.call(*args)
    end
  end

end
