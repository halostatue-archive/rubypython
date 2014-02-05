# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe 'Reference Counting' do
  it "is one given a new object" do
    pyObj = @objects.RubyPythonMockObject.new
    expect(get_refcnt(pyObj)).to eq 1
  end

  it "increases when a new reference is passed into Ruby" do
    pyObj = @objects.RubyPythonMockObject
    refcnt = get_refcnt(pyObj)
    pyObj2 = @objects.RubyPythonMockObject
    expect(get_refcnt(pyObj)).to eq (refcnt + 1)
  end

  describe RubyPython::PyObject do
    describe "#xIncref" do
      it "increases the reference count" do
        pyObj = @objects.RubyPythonMockObject.new
        refcnt = get_refcnt(pyObj)
        pyObj.pObject.xIncref
        expect(get_refcnt(pyObj)).to eq refcnt + 1
      end
    end

    describe "#xDecref" do
      it "decreases the reference count" do
        pyObj = @objects.RubyPythonMockObject.new
        pyObj.pObject.xIncref
        refcnt = get_refcnt(pyObj)
        pointer = pyObj.pObject.pointer
        pyObj.pObject.xDecref
        expect(get_refcnt(pointer)).to eq refcnt - 1
      end
    end
  end

  describe RubyPython::Conversion do
    describe ".rtopArrayToList" do
      it "increments the references around wrapped objects in the array" do
        int = RubyPython::PyObject.new RPTest::AnInt
        refcnt = get_refcnt(int)
        arr = [ int ]
        pyArr = subject.rtopArrayToList(arr)
        expect(get_refcnt(int)).to eq refcnt + 1
      end
    end

    describe ".rtopObject" do
      [
        ["string", RPTest::AString],
        ["float", RPTest::AFloat],
        ["array", RPTest::AnArray],
        #["symbol", RPTest::ASym],
        ["hash", RPTest::AHash]
      ].each do |arr|
        type, input = arr

        it "returns a refcnt of 1 for newly created #{type}" do
          pyObj = subject.rtopObject(input)
          expect(get_refcnt(pyObj)).to eq 1
        end

        it "increments the refcnt each time the same #{type} is passed in" do
          pyObj = RubyPython::PyObject.new subject.rtopObject(input)
          refcnt = get_refcnt(pyObj)
          pyObj2 = subject.rtopObject(pyObj)
          expect(get_refcnt(pyObj2)).to eq refcnt + 1
        end
      end
    end
  end
end
