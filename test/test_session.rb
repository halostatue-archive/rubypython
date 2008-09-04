class TestSessionImport < Test::Unit::TestCase
  def test_session
    require 'rubypython/session'
    File.dirname(__FILE__) + '/../lib/rubypython'
    assert RubyPython.import "cPickle"
  end
end