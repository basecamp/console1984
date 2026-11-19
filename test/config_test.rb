require "test_helper"

class ConfigTest < ActiveSupport::TestCase
  test "false values will replace the config values" do
    original = Console1984.incinerate
    Console1984.config.set_from({incinerate: false})
    refute Console1984.incinerate
  ensure
    Console1984.config.incinerate = original
  end
end
