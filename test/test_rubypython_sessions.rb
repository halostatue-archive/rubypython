
require File.dirname(__FILE__) + '/test_helper.rb'

class TestRubySessions < Test::Unit::TestCase
  @@pickledObject = {1 => [0,1,2], 'STRING' => 4.9}


  def test_cpickle_session
    RubyPython.session do

      cPickle = RubyPython.import 'cPickle'
      data = File.open('test/fixture1.pickle'){|x| x.read}
      depickledObject = cPickle.loads data
      assert_equal(@@pickledObject,
                  depickledObject.rubify,
                  "Failed to correctly depickle an object")

      assert_raise RubyPython::PythonError do 
        cPickle.loads "INVALID STRING"
      end
    end

  end

end
