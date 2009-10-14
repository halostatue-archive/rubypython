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
    
    assert_instance_of(RubyPythonBridge::RubyPyModule,
                       cPickle,
                       "Module object not returned by import.")
    
    assert_equal({"a"=>"n", [1, "2"]=>4},
                 cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."),
                 "Python pickle load test returned incorrect objects.")

    dumped_array=cPickle.dumps([1,2,3,4])
    
    assert_equal([1,2,3,4],
                 cPickle.loads(dumped_array),
                 "Pickled information was not retrieved correctly.")
    
    assert_raise(NoMethodError, "Rubypython failed to raise NoMethodError on call to nonexistent method") do
      cPickle.splack
    end
    
    assert_instance_of(RubyPythonBridge::RubyPyClass,
                       cPickle.PicklingError,
                       "Wrapped Python class was not of type RubyPyClass.")
    
    cPickle.free_pobj
    
    ObjectSpace.each_object(RubyPythonBridge::RubyPyObject) do |o|
      o.free_pobj
    end
    
    assert(RubyPython.stop,"Interpreter did not halt correctly.")
  end

  def test_two_imports
    RubyPython.start
    assert_nothing_raised("Error raised on imports") do
      RubyPython.import "cPickle"
      RubyPython.import "urllib"
    end
    RubyPython.stop
  end

  def test_propogate_python_error
    RubyPython.start
    
    assert_raise(PythonError,"rubypython failed to propogate python error.") do
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
    
    assert_equal({"a"=>"n", [1, "2"]=>4},
                 unpickled,
                 "Incorrect object returned from cPickle.")
    
    assert(!RubyPython.stop, "RubyPython did not seem to halt at the correct time.")
  end

  def test_instance_method_delegation
    RubyPython.start
    
    wave=RubyPython.import "wave"
    w=wave.open("test/test.wav","rb")
    assert_equal(9600,
                 w.getframerate,
                 "Wrapped wave library incorrectly passing framerate.")
    w.close
    
    RubyPython.stop
  end

  def test_pymain_delegation
    RubyPython.start
    
    assert_equal(42.to_f,
                 PyMain.float(42),
                 "Integer conversion problems in Python.")
    
    RubyPython.stop
  end

  def test_block_syntax
    returned=""
    
    RubyPython.start
    
    returned = PyMain.float(22) do |f|
      f*2
    end
    
    assert_equal(44.0,
                 returned,
                 "Wrapped Python object failed to correctly utilize block syntax.")
    
    RubyPython.stop
  end
  
  def test_session_function
    RubyPython.session do
      
      cPickle=RubyPython.import "cPickle"
      
      cPickle.inspect
      
      assert_equal({"a"=>"n", [1, "2"]=>4},
                   cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."),
                   "cPickle misbehaved in session block.")
    end
  end

  
  def test_setter_ary
    RubyPython.session do
      
      sys=RubyPython.import 'sys'
      
      sys.path=[".",".."]
      
      assert_equal([".",".."],
                   sys.path,
                   "Ruby failed to modify Python object as expected.")
    end
  end
  
  def test_setter_instance
    RubyPython.session do
      urllib2=RubyPython.import "urllib2"
      req=urllib2.Request("google.com")
      req.headers={:a=>"2","k"=>4}
      assert_equal({"a"=>"2","k"=>4},
                   req.headers,
                   "Python dictionary not set as expected.")
    end
  end
  
  def test_set_twice
    RubyPython.session do
      sys = RubyPython.import 'sys'
      
      sys.path = ['.']
      
      sys.path = ['..']
      
      assert_equal(['..'],
                   sys.path,
                   "Ruby failed to modify Python object as expected.")
      
    end
  end
  
  def test_python_persistence
    RubyPython.session do
      sys = RubyPython.import 'sys'
      
      path = sys.path
      
      path2 = sys.path
      
    end
  end

end

#class TestUnitarity < Test::Unit::TestCase
