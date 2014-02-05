# -*- ruby encoding: utf-8 -*-

require 'spec_helper'

describe RubyPython::PyMainClass do
  subject { RubyPython::PyMain }

  it "delegates to builtins" do
    expect(subject.float(RPTest::AnInt).rubify).to eq RPTest::AnInt.to_f
  end

  it "handles block syntax" do
    expect(subject.float(RPTest::AnInt) { |f| f.rubify*2 }).to \
      eq (RPTest::AnInt.to_f * 2)
  end

  it "allows attribute access" do
    expect(subject.main.__name__.rubify).to eq '__main__'
  end

  it "allows global variable setting" do
    subject.x = 2
    expect(subject.x.rubify).to eq 2
  end
end
