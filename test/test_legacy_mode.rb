require File.dirname(__FILE__) + '/test_helper.rb'

class TestRubypythonLegacy < Test::Unit::TestCase
  

  def setup
    RubyPython.legacy_mode = true
  end

  def teardown
    RubyPython.legacy_mode = false
  end

  def test_delegation
    RubyPython.start
    cPickle = RubyPython.import("cPickle")
    
    assert_instance_of(RubyPythonBridge::RubyPyModule,
                       cPickle,
                       "Module object not returned by import.")
    
    assert_equal({"a"=>"n", [1, "2"]=>4},
                 cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."),
                 "Python pickle load test returned incorrect objects.")

    dumped_array = cPickle.dumps([1,2,3,4])
    
    assert_equal([1,2,3,4],
                 cPickle.loads(dumped_array),
                 "Pickled information was not retrieved correctly.")
    
    assert_raise(NoMethodError, "Rubypython failed to raise NoMethodError on call to nonexistent method") do
      cPickle.splack
    end
    
    assert_instance_of(RubyPythonBridge::RubyPyClass,
                       cPickle.PicklingError,
                       "Wrapped Python class was not of type RubyPyClass.")
    
    
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
    unpickled = nil
    
    RubyPython.run do
      cPickle = import "cPickle"
      cPickle.inspect
      unpickled = cPickle.loads("(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.")
    end
    
    assert_equal({"a"=>"n", [1, "2"]=>4},
                 unpickled,
                 "Incorrect object returned from cPickle.")
    
    assert(!RubyPython.stop, "RubyPython did not seem to halt at the correct time.")
  end

  def test_instance_method_delegation
    RubyPython.start
    
    wave = RubyPython.import "wave"
    w = wave.open("test/test.wav","rb")
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
      
      cPickle = RubyPython.import "cPickle"
      
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
      urllib2 = RubyPython.import "urllib2"
      req = urllib2.Request("google.com")
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

end

class TestLegacyWithCustomObject < Test::Unit::TestCase
  def setup
    RubyPython.legacy_mode = true
    RubyPython.start
    sys = RubyPython.import 'sys'
    sys.path = ['./test/python_helpers']
    @objects = RubyPython.import 'objects'
  end
  
  def teardown
    RubyPython.stop
    RubyPython.legacy_mode = false
  end
  
  def test_string_access
    assert_equal("STRING",
           @objects.RubyPythonMockObject.STRING,
           "String class members not being converted correctly.")
    rbString = @objects.RubyPythonMockObject.STRING
  end
  
  def test_string_ary_access
    assert_equal(["STRING1", "STRING2"],
                 @objects.RubyPythonMockObject.STRING_LIST,
                 "List of strings class member not being converted correctly.")
    rbStringList = @objects.RubyPythonMockObject.STRING_LIST
  end
  
  def test_string_ary_modify
    rbStringList = @objects.RubyPythonMockObject.STRING_LIST
    rbStringList.push"NEW_STRING"
    @objects.RubyPythonMockObject.STRING_LIST = rbStringList
    assert_equal("NEW_STRING",
                @objects.RubyPythonMockObject.STRING_LIST[2],
                "Failed to add object to list.")
  end
end

class TestLegacyWithCPickle < Test::Unit::TestCase
  def setup
    RubyPython.legacy_mode = true
    RubyPython.start
    @cPickle=RubyPython.import "cPickle"
  end
  
  def teardown
    RubyPython.stop
    RubyPython.legacy_mode = false
  end
  
  def test_mod_respond_to
    assert(@cPickle.respond_to?(:loads),
           "Ruby respond to method not working on wrapped module.")
  end
  
  def test_data_passing
    assert_equal({"a"=>"n", [1, "2"]=>4},
                 @cPickle.loads( "(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."),
                 "Data returned from wrapped cPickle is incorrect." )
    
    orig_array = [1,2,3,4]
    dumped_array = @cPickle.dumps(orig_array)
    
    assert_equal(orig_array,
                 @cPickle.loads(dumped_array),
                 "Array returned from cPickle is not equivalent to input array.")
  end
  
  def test_unknown_method
    assert_raise(NoMethodError, "Missing method failed to raise NoMethodError") do
      @cPickle.splack
    end
  end
  
  def test_class_wrapping
    assert_instance_of(RubyPythonBridge::RubyPyClass,
                       @cPickle.PicklingError,
                       "Wrapped class is not an instance of RubyPyClass.")
  end
  
  def test_module_wrapping
    assert_instance_of(RubyPythonBridge::RubyPyModule,
                       @cPickle,
                       "Wrapped module is not of class RubyPyModule.")
  end
  
end


class TestLegacyWithUrllib2 < Test::Unit::TestCase
  def setup
    RubyPython.legacy_mode = true
    RubyPython.start
    @urllib2=RubyPython.import "urllib2"
  end
  
  def teardown
    RubyPython.stop
    RubyPython.legacy_mode = false
  end
  
  def test_class_respond_to
    assert(@urllib2.Request.respond_to?(:get_data),
          "respond_to? method call failed on RubyPyClass")
  end
  
  def test_instance_respond_to
    assert(@urllib2.Request.new("google.com").respond_to?(:get_data),
          "respond_to? method call failed on RubyPyInstance")
  end
  
end
