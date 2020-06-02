require "test_helper"

class AuditingTest < ActiveSupport::TestCase
  setup do
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")
  end

  teardown do
    @console.stop
  end

  test "executing commands show the output" do
    @console.execute <<~RUBY
      puts "Result is \#{1+1}"
    RUBY

    assert @console.output.include?("Result is 2")
  end

  test "executing commands log an audit trail with reason, user and executed commands" do
    @console.execute "1+1"
    audit_trail = @console.last_audit_trail
    assert_audit_trail audit_trail, user: "jorge", commands: "1+1" do |access_reason|
      assert_equal "Some very good reason", access_reason.for_session
    end
  end

  test "can execute multiple commands" do
    %w[ 1+1 2+2 3+3 ].each do |commands|
      @console.execute commands
      audit_trail = @console.last_audit_trail
      assert_audit_trail audit_trail, user: "jorge", commands: commands do |access_reason|
        assert_equal "Some very good reason", access_reason.for_session
      end
    end
  end

  test "captures ActiveRecord output" do
    @console.execute "puts Person.last.name"
    assert @console.last_json_entry.include?(%q{SELECT \"people\".* FROM \"people\" ORDER BY \"people\".\"id\" DESC LIMIT})
  end

  test "commands in protected mode are not flagged as sensitive" do
    @console.execute "puts Person.last.name"
    assert_not @console.last_audit_trail.sensitive
  end

  test "can log further reasons with the log command" do
    @console.execute "log 'I really need the name OMG'"
    @console.execute "puts Person.last.name"
    assert_audit_trail @console.last_audit_trail, sensitive: false do |access_reason|
      assert_equal "I really need the name OMG", access_reason.for_commands
    end
  end

  test "commands in unprotected mode are justified and flagged as sensitive" do
    type_when_prompted "I need to fix encoding issue with Message 123456" do
      @console.execute "decrypt!"
    end
    @console.execute "puts Person.last.name"

    assert_audit_trail @console.last_audit_trail, sensitive: true do |access_reason|
      assert_equal "I need to fix encoding issue with Message 123456", access_reason.for_sensitive_access
    end
  end

  private
    def assert_audit_trail(audit_trail, expected_properties)
      expected_properties.each do |key, value|
        assert_equal value, audit_trail.send(key)
      end

      yield audit_trail.access_reason
    end
end
