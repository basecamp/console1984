require "test_helper"

class AuditingTest < ActiveSupport::TestCase
  setup do
    @console = SupervisedTestConsole.new(user: "jorge", reason: "Some very good reason")
  end

  teardown do
    @console.stop
  end

  test "executing statements show the output" do
    @console.execute <<~RUBY
      puts "Result is \#{1+1}"
    RUBY

    assert @console.output.include?("Result is 2")
  end

  test "executing statements log an audit trail with reason, user and executed statements" do
    @console.execute "1+1"
    audit_trail = @console.last_audit_trail
    assert_audit_trail audit_trail, user: "jorge", reason: "Some very good reason", statements: "1+1"
  end

  test "can execute multiple statements" do
    %w[ 1+1 2+2 3+3 ].each do |statements|
      @console.execute statements
      audit_trail = @console.last_audit_trail
      assert_audit_trail audit_trail, user: "jorge", reason: "Some very good reason", statements: statements
    end
  end

  test "captures ActiveRecord output" do
    @console.execute "puts Person.last.name"
    assert @console.last_json_entry.include?(%q{SELECT \"people\".* FROM \"people\" ORDER BY \"people\".\"id\" DESC LIMIT})
  end

  private
    def assert_audit_trail(audit_trail, expected_properties)
      expected_properties.each do |key, value|
        assert_equal value, audit_trail.send(key)
      end
    end
end
