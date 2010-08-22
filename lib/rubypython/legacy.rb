require 'rubypython'

module RubyPython::LegacyMode
  class << self
    def setup_legacy
      RubyPython.legacy_mode = true
    end

    def teardown_legacy
      RubyPython.legacy_mode = false
    end
  end
end

RubyPython::LegacyMode.setup_legacy
