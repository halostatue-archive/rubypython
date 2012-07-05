require File.dirname(__FILE__) + '/spec_helper.rb'

def get_refcnt(pobject)
  raise 'Cannot work with a nil object' if pobject.nil?

  if pobject.kind_of? RubyPython::RubyPyProxy
    pobject = pobject.pObject.pointer
  elsif pobject.kind_of? RubyPython::PyObject
    pobject = pobject.pointer
  end
  struct = RubyPython::Python::PyObjectStruct.new pobject
  struct[:ob_refcnt]
end

include TestConstants

describe 'Reference Counting' do
  before :all do
    RubyPython.start
    @sys = RubyPython.import 'sys'
    @sys.path.append './spec/python_helpers'
    @objects = RubyPython.import 'objects'
  end

  after :all do
    RubyPython.stop
  end

  it "should be one given a new object" do
    pyObj = @objects.RubyPythonMockObject.new
    get_refcnt(pyObj).should == 1
  end

  it "should increase when a new reference is passed into Ruby" do
    pyObj = @objects.RubyPythonMockObject
    refcnt = get_refcnt(pyObj)
    pyObj2 = @objects.RubyPythonMockObject
    get_refcnt(pyObj).should == (refcnt + 1)
  end

  describe RubyPython::PyObject do
    describe "#xIncref" do
      it "should increase the reference count" do
        pyObj = @objects.RubyPythonMockObject.new
        refcnt = get_refcnt(pyObj)
        pyObj.pObject.xIncref
        get_refcnt(pyObj).should == refcnt + 1
      end
    end

    describe "#xDecref" do
      it "should decrease the reference count" do
        pyObj = @objects.RubyPythonMockObject.new
        pyObj.pObject.xIncref
        refcnt = get_refcnt(pyObj)
        pointer = pyObj.pObject.pointer
        pyObj.pObject.xDecref
        get_refcnt(pointer).should == refcnt - 1
      end
    end
  end
end
