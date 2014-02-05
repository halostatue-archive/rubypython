# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe RubyPython::RubyPyClass do
  describe "#new" do
    it "returns a RubyPyInstance" do
      urllib2 = RubyPython.import 'urllib2'
      expect(urllib2.Request.new('google.com')).to \
        be_a RubyPython::RubyPyInstance
    end
  end
end
