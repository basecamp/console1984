require "test_helper"

class BigBrotherTest < ActiveSupport::TestCase
  setup do
    @string_io = StringIO.new
    @logger = ActiveSupport::Logger.new(@string_io)
    @big_brother = OrwellConsole::BigBrother.new(logger: @logger)

    ENV["CONSOLE_USER"] = "Jorge"

    type_when_prompted "Testing the console" do
      @big_brother.supervise
    end
  end

  test "executing statements will stream an audit trail through its logger" do
    @big_brother.executed(["Rails.logger.info 'JORGE'"])

    audit_trail = OpenStruct.new JSON.parse(@string_io.string)["console"]
    assert "Jorge", audit_trail.user
    assert "Testing the console", audit_trail.reason
    assert "Rails.logger.info 'JORGE'", audit_trail.statements
  end

  private
    def type_when_prompted(*list, &block)
      $stdin.stub(:gets, proc { list.shift }, &block)
    end
end
