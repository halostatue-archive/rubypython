require File.dirname(__FILE__) + '/spec_helper.rb'

include TestConstants

describe 'RubyPython Legacy Mode Module' do
  include RubyPythonStartStop

  before :all do
    require 'rubypython/legacy'
  end

  after :all do
    RubyPython::LegacyMode.teardown_legacy
  end

  describe "when required" do
    it "should enable legacy mode" do
      RubyPython.legacy_mode.should == true
    end
  end

end
