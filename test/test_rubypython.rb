require File.dirname(__FILE__) + '/test_helper.rb'

class TestRubypython < Test::Unit::TestCase

  def setup
  end
  

  def test_simple
    assert(RubyPython.start,"RubyPython failed to initialize.")
    assert(RubyPython.import("urllib"), "urllib library import failed.")
    assert(RubyPython.stop,"RubyPython failed to halt.")
    assert(!RubyPython.stop,"RubyPython did not realize it had halted.")
  end

  def test_delegation
    RubyPython.start
    cPickle=RubyPython.import("cPickle")
    assert_instance_of(RubyPythonBridge::RubyPyModule,cPickle)
    assert_equal({"a"=>"n", [1, "2"]=>4},cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."))
    dumped_array=cPickle.dumps([1,2,3,4])
    assert_equal([1,2,3,4],cPickle.loads(dumped_array))
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

  def test_propogate_python_error
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
    assert_equal({"a"=>"n", [1, "2"]=>4},unpickled)
    assert(!RubyPython.stop)
  end

  def test_instance_method_delegation
    RubyPython.start
    wave=RubyPython.import "wave"
    w=wave.open("test/test.wav","rb")
    assert_equal(9600,w.getframerate)
    w.close
    RubyPython.stop
  end

  def test_pymain_delegation
    RubyPython.start
    assert_equal(42.to_f,PyMain.float(42))
    RubyPython.stop
  end

  def test_block_syntax
    returned=""
    RubyPython.start
    returned=PyMain.float(22) do |f|
      f*2
    end
    assert_equal(44.0,returned)
    RubyPython.stop
  end
  
  def test_session_function
    RubyPython.session do
      cPickle=RubyPython.import "cPickle"
      cPickle.inspect
      assert_equal({"a"=>"n", [1, "2"]=>4},cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."))
    end
  end

  
  def test_setter_ary
    RubyPython.session do
      sys=RubyPython.import 'sys'
      sys.path=[""]
      assert_equal([""],sys.path)
    end
  end
  
  def test_setter_instance
    RubyPython.session do
      urllib2=RubyPython.import "urllib2"
      req=urllib2.Request("google.com")
      req.headers={:a=>"2","k"=>4}
      assert_equal({"a"=>"2","k"=>4},req.headers)
    end
  end

end
