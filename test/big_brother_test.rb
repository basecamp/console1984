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
    @big_brother.supervise_execution_of ["1+1"] do
      1+1
    end

    audit_trail = OpenStruct.new JSON.parse(@string_io.string)["console"]
    assert_equal "Jorge", audit_trail.user
    assert_equal "Testing the console", audit_trail.reason
    assert_equal "1+1", audit_trail.statements
  end

  private
    def type_when_prompted(*list, &block)
      $stdin.stub(:gets, proc { list.shift }, &block)
    end
end
