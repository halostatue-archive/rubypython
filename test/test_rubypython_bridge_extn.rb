require "test/unit"

$:.unshift File.dirname(__FILE__) + "/../ext/rubypython_bridge"
require "rubypython_bridge.so"

class TestRubypythonBridgeExtn < Test::Unit::TestCase
  
  def test_func_with_module
    pickle_return=RubyPythonBridge.func("cPickle","loads","(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.")
    assert_equal(pickle_return,{"a"=>"n", [1, "2"]=>4})
  end
  
  def test_module_delegation
    RubyPythonBridge.start
    cPickle=RubyPythonBridge.import("cPickle")
    assert_instance_of(RubyPythonBridge::RubyPyModule,cPickle)
    assert_equal(cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."),{"a"=>"n", [1, "2"]=>4})
    dumped_array=cPickle.dumps([1,2,3,4])
    assert_equal(cPickle.loads(dumped_array),[1,2,3,4])
    assert_raise NoMethodError do
      cPickle.splack
    end
    assert_instance_of(RubyPythonBridge::RubyPyClass,cPickle.PicklingError)
    cPickle.free_pobj
    ObjectSpace.each_object(RubyPythonBridge::RubyPyObject) do |o|
      o.free_pobj
    end
    assert(RubyPythonBridge.stop)
  end  
end