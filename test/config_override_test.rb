require 'test_helper'

class ConfigOverrideTest < ActiveSupport::TestCase
  teardown do
    @console.stop
  end

  test "setting justification_message in config overrides default message" do
    original = Console1984.config.justification_message
    Console1984.config.justification_message = "foobar"
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")

    type_when_prompted "will our test pass?" do
      @console.execute "decrypt!"
    end

    assert_includes @console.output, "foobar"

    Console1984.config.justification_message = original
  end

  test "setting commands_list in config overrides default message" do
    original = Console1984.config.commands_list
    Console1984.config.commands_list = {"new_command": "new help line"}
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")

    assert_includes @console.output, "new_command"
    assert_includes @console.output, "new help line"

    Console1984.config.commands_list = original
  end

  test "setting show_commands to false does not show commands list" do
    Console1984.config.show_commands_message = false
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")

    assert_not_includes @console.output, "decrypt!"
    
    Console1984.config.show_commands_message = true
  end
end

