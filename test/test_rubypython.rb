require File.dirname(__FILE__) + '/test_helper.rb'

class TestRubypython < Test::Unit::TestCase

  def setup
  end

  def test_simple
    assert RubyPython.start
    assert RubyPython.import "urllib"
    assert(RubyPython.stop)
    assert(!RubyPython.stop)
  end

  def test_delegation
    RubyPython.start
    cPickle=RubyPython.import("cPickle")
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
    assert(RubyPython.stop)
  end

  def test_two_imports
    RubyPython.start
    RubyPython.import "cPickle"
    RubyPython.import "urllib"
    RubyPython.stop
  end

  def test_propogate_python_errror
    RubyPython.start
    assert_raise PythonError do
      RubyPython.import "slasdfj"
    end
    RubyPython.stop
  end

  def test_run_method
    unpickled=nil
    RubyPython.run do
      cPickle=import "cPickle"
      cPickle.inspect
      unpickled=cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.")
    end
    assert_equal(unpickled,{"a"=>"n", [1, "2"]=>4})
    assert(!RubyPython.stop)
  end

  def test_instance_method_delegation
    RubyPython.start
    wave=RubyPython.import "wave"
    w=wave.open("test/test.wav","rb")
    assert_equal(w.getframerate,9600)
    w.close
    RubyPython.stop
  end

  def test_pymain_delegation
    RubyPython.start
    assert_equal(PyMain.float(42),42.to_f)
    RubyPython.stop
  end

  def test_block_syntax
    returned=""
    RubyPython.start
    returned=PyMain.float(22) do |f|
      f*2
    end
    assert_equal(returned,44.0)
    RubyPython.stop
  end
  
  def test_session_function
    RubyPython.session do
      cPickle=RubyPython.import "cPickle"
      cPickle.inspect
      assert_equal(cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."),{"a"=>"n", [1, "2"]=>4})
    end
  end

  


end
