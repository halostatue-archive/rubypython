# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe RubyPython::PythonError do
  def cause_error
    RubyPython::Python.PyImport_ImportModule("wat")
  end

  describe "#error?" do
    it "returns false when no error has occured" do
      expect(described_class.error?).to eq false
    end

    it "returns true when an error has occured" do
      cause_error
      expect(described_class.error?).to eq true
    end
  end

  describe "#clear" do
    it "resets the Python error flag" do
      cause_error
      described_class.clear
      expect(described_class.error?).to eq false
    end

    it "does not barf when there is no error" do
      expect {
        described_class.clear
      }.not_to raise_exception
    end
  end

  describe "#fetch" do
    it "makes available the Python error type" do
      cause_error
      rbType, rbValue, rbTraceback = described_class.fetch
      expect(rbType.getAttr("__name__").rubify).to eq "ImportError"
    end
  end

  describe ".last_traceback" do
    it "makes available the Python traceback of the last error" do
      traceback = RubyPython.import 'traceback'
      errors = RubyPython.import 'errors'
      begin
        errors.nested_error
      rescue RubyPython::PythonError => exc
        tb = exc.traceback
        list = traceback.format_tb(tb)
        expect(list.rubify[0]).to match %r{1 / 0}
      end
    end
  end
end
