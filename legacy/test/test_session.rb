class TestSessionImport < Test::Unit::TestCase
  def test_session
    require 'rubypython/session'
    assert(RubyPython.import("cPickle"), "Import failed during session test.")
  end
end