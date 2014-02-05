# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe "RubyPython" do
  it "can import and use a native extension like cPickle" do
    cPickle = RubyPython.import("cPickle")
    string  = cPickle.dumps("Testing RubyPython.")
    expect(string).not_to be_a_kind_of String
    expect(string.rubify).to be_a_kind_of String
    expect(string.rubify).to match /S'Testing RubyPython.'\n/
  end

  it "can import and use a pure Python extension like pickle" do
    pickle = RubyPython.import("pickle")
    string = pickle.dumps("Testing RubyPython.")
    expect(string).not_to be_a_kind_of String
    expect(string.rubify).to be_a_kind_of String
    expect(string.rubify).to match /S'Testing RubyPython.'\n/
  end

  it "can use iterators from Python" do
    items = []
    @basics.iterate_list.to_enum.each { |item| items << item }
    expect(items).to eq [ 1, 2, 3 ]
  end

  it "can use Ruby procs as callbacks to Python code" do
    expect(@basics.simple_callback(lambda { |v| v * v }, 4)).to eq 16
  end

  it "can use Ruby methods as callbacks to Python code" do
    def triple(v)
      v * 3
    end
    expect(@basics.simple_callback(method(:triple), 4)).to eq 12
  end

  it "can feed a Python generator in Ruby 1.9", :ruby_version => '1.9' do
    output = @basics.simple_generator(RubyPython.generator do
      (1..10).each { |i| RubyPython.yield i }
    end)
    expect(output).to eq [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
  end

  it "can use named parameters to functions" do
    expect(@basics.named_args(2, 1)).to eq [ 2, 1 ]
    expect(@basics.named_args!(:arg2 => 2, :arg1 => 1)).to eq [ 1, 2 ]
  end
end
