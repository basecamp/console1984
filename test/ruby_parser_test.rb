require "test_helper"

class RubyParserTest < ActiveSupport::TestCase
  test "ruby_parser returns the appropriate parser for the current Ruby version" do
    if RUBY_VERSION >= "3.3"
      assert_equal Prism::Translation::ParserCurrent, Console1984.ruby_parser
    else
      assert_equal Parser::CurrentRuby, Console1984.ruby_parser
    end
  end
end
