require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants

describe "RubyPython" do
  it "can import and use a native extension like cPickle" do
    cPickle = RubyPython.import("cPickle")
    string = cPickle.dumps("Testing RubyPython.")
    string.should_not be_a_kind_of String
    string.rubify.should be_a_kind_of String
    string.rubify.should ~ /S'Testing RubyPython.'\n/
  end

  it "can import and use a pure Python extension like pickle" do
    pickle = RubyPython.import("pickle")
    string = pickle.dumps("Testing RubyPython.")
    string.should_not be_a_kind_of String
    string.rubify.should be_a_kind_of String
    string.rubify.should ~ /S'Testing RubyPython.'\n/
  end

  it "can use iterators from Python" do
    items = []
    @basics.iterate_list.to_enum.each { |item| items << item }
    items.should == [ 1, 2, 3 ]
  end

  it "can use Ruby procs as callbacks to Python code" do
    @basics.simple_callback(lambda { |v| v * v }, 4).should == 16
  end

  it "can use Ruby methods as callbacks to Python code" do
    def triple(v)
      v * 3
    end
    @basics.simple_callback(method(:triple), 4).should == 12
  end

  it "can feed a Python generator in Ruby 1.9", :ruby_version => '1.9' do
    output = @basics.simple_generator(RubyPython.generator do
      (1..10).each { |i| RubyPython.yield i }
    end)
    output.should == [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
  end

  it "can use named parameters to functions" do
    @basics.named_args(2, 1).should == [ 2, 1 ]
    @basics.named_args!(:arg2 => 2, :arg1 => 1).should == [ 1, 2 ]
  end
end
