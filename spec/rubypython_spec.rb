# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe RubyPython do
  describe "#import" do
    it "handles multiple imports" do
      expect {
        RubyPython.import 'cPickle'
        RubyPython.import 'urllib'
      }.not_to raise_exception
    end

    it "propagates Python errors" do
      expect {
        RubyPython.import 'nonExistentModule'
      }.to raise_exception(RubyPython::PythonError)
    end

    it "returns a RubyPyModule" do
      expect(RubyPython.import('urllib2')).to be_a(RubyPython::RubyPyModule)
    end
  end
end

describe RubyPython, :self_start => true do
  let(:pickled) { "(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns." }
  let(:unpickled) { { "a" => "n", [ 1, "2" ] => 4 } }

  describe "#session" do
    it "starts the interpreter" do
      RubyPython.session do
        cPickle = RubyPython.import "cPickle"
        expect(cPickle.loads(pickled).rubify).to eq unpickled
      end
    end

    it "stops the interpreter" do
      RubyPython.session do
        cPickle = RubyPython.import "cPickle"
      end

      expect(RubyPython.stop).to eq false
    end
  end

  describe "#run" do
    it "starts the interpreter" do
      RubyPython::PICKLED = pickled
      result = RubyPython.run do
        cPickle = import "cPickle"
        cPickle.loads(RubyPython::PICKLED).rubify
      end
      expect(result).to eq unpickled
    end

    it "stops the interpreter" do
      RubyPython.run do
        cPickle = import "cPickle"
      end

      expect(RubyPython.stop).to eq false
    end
  end
end
