# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe 'Callbacks' do
  {
    'procs'   => RPTest::AProc,
    'methods' => RPTest::AMethod,
  }.each do |rb_type, rb_object|
    specify "accept #{rb_type} as functions" do
      [
        [2, 2],
        ["a", "Word"],
        [ [1, 2], [3, 4] ]
      ].each do |args|
        @objects.apply_callback(rb_object, args)

        expect(@objects.apply_callback(rb_object, args)).to \
          eq rb_object.call(*args)
      end
    end
  end

  [
    ["an int", RPTest::AnInt],
    ["a float", RPTest::AFloat],
    ["a string", RPTest::AString],
    ["a string with nulls", RPTest::AStringWithNULLs],
    ["an array", RPTest::AnArray],
    ["an array", RPTest::AnArray],
    ["a hash", RPTest::AConvertedHash],
    ["true", true],
    ["false", false],
    ["nil", nil]
  ].each do |rb_type, rb_value|
    it "is able to return #{rb_type}" do
      callback = Proc.new do
        rb_value
      end

      expect(@objects.apply_callback(callback, [])).to eq rb_value
    end
  end

  it "is able to be stored by python variables" do
    mockObject = @objects.RubyPythonMockObject.new
    expect {
      mockObject.callback = RPTest::AProc
    }.not_to raise_error
  end

  it "is callable as a python instance variable" do
    mockObject = @objects.RubyPythonMockObject.new
    mockObject.callback = RPTest::AProc
    expect(mockObject.callback(2, 2).rubify).to eq 4
  end
end
