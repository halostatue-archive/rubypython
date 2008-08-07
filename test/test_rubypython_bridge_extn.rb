require "test/unit"

$:.unshift File.dirname(__FILE__) + "/../ext/rubypython_bridge"
require "rubypython_bridge.so"

class TestRubyPythonBridgeExtn < Test::Unit::TestCase
  
  def test_func_with_module
    pickle_return=RubyPythonBridge.func("cPickle","loads","(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.")
    assert_equal(pickle_return,{"a"=>"n", [1, "2"]=>4})
  end
  
  def test_start_stop
    assert(RubyPythonBridge.start)
    assert(!RubyPythonBridge.start)
    assert(RubyPythonBridge.stop)
    assert(!RubyPythonBridge.stop)
  end
  
  def test_new_instance
    RubyPythonBridge.start
    urllib2=RubyPythonBridge.import "urllib2"
    assert_instance_of(RubyPythonBridge::RubyPyClass,urllib2.Request)
    assert_instance_of(RubyPythonBridge::RubyPyInstance,urllib2.Request("google.com"))
    RubyPythonBridge.stop
  end
  
  def test_new_instance_with_new_method
    RubyPythonBridge.start
    urllib2=RubyPythonBridge.import "urllib2"
    assert_instance_of(RubyPythonBridge::RubyPyClass,urllib2.Request)
    assert_instance_of(RubyPythonBridge::RubyPyInstance,urllib2.Request.new("google.com"))
    RubyPythonBridge.stop
  end
  
end

class TestRubyPythonBridgeWithCPickle < Test::Unit::TestCase
  def setup
    RubyPythonBridge.start
    @cPickle=RubyPythonBridge.import "cPickle"
  end
  
  def teardown
    ObjectSpace.each_object(RubyPythonBridge::RubyPyObject) do |o|
      o.free_pobj
    end
    RubyPythonBridge.stop
  end
  
  def test_mod_respond_to
    assert(@cPickle.respond_to? :loads)
  end
  
  def test_data_passing
    assert_equal(@cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."),{"a"=>"n", [1, "2"]=>4})
    dumped_array=@cPickle.dumps([1,2,3,4])
    assert_equal(@cPickle.loads(dumped_array),[1,2,3,4])
  end
  
  def test_method_missing
    assert_raise NoMethodError do
      @cPickle.splack
    end
  end
  
  def test_class_wrapping
    assert_instance_of(RubyPythonBridge::RubyPyClass,@cPickle.PicklingError)
  end
  
  def test_module_method_wrapping
    assert_instance_of(RubyPythonBridge::RubyPyModule,@cPickle)
  end
  
end


class TestRubyPythonBridgeWithUrllib2 < Test::Unit::TestCase
  def setup
    RubyPythonBridge.start
    @urllib2=RubyPythonBridge.import "urllib2"
  end
  
  def teardown
    ObjectSpace.each_object(RubyPythonBridge::RubyPyObject) do |o|
      o.free_pobj
    end
    RubyPythonBridge.stop
  end
  
  def test_class_respond_to
    assert(@urllib2.Request.respond_to? :get_data)
  end
  
  def test_instance_respond_to
    assert(@urllib2.Request.new("google.com").respond_to? :get_data)
  end
  
end

