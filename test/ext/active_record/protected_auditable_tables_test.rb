require "test_helper"

class Console1984::Ext::ActiveRecord::ProtectedAuditableTablesTest < ActiveSupport::TestCase
  # Stands in for the underlying adapter; the shield is prepended on top.
  class FakeConnection
    attr_reader :received

    def exec_insert_all(*args, **kwargs)
      @received = args.first
      :executed
    end

    prepend Console1984::Ext::ActiveRecord::ProtectedAuditableTables
  end

  # Mimics what exec_insert_all actually receives: an ActiveRecord::InsertAll,
  # which responds to #model but not to #b.
  InsertAll = Struct.new(:model)

  setup do
    # Make sure the audit models are loaded so auditable_tables_regexp isn't empty.
    [ Console1984::Session, Console1984::Command, Console1984::SensitiveAccess, Console1984::User ]
    @connection = FakeConnection.new
  end

  test "an InsertAll for a non-auditable table is allowed and passed through untouched" do
    insert_all = InsertAll.new(Person)

    result = as_user { @connection.exec_insert_all(insert_all, "Person Bulk Insert") }

    assert_equal :executed, result
    assert_same insert_all, @connection.received
  end

  test "an InsertAll for an auditable table is still forbidden" do
    insert_all = InsertAll.new(Console1984::Session)

    assert_raises Console1984::Errors::ForbiddenCommandAttempted do
      as_user { @connection.exec_insert_all(insert_all, "Session Bulk Insert") }
    end
  end

  test "string SQL is still checked against auditable tables" do
    assert_raises Console1984::Errors::ForbiddenCommandAttempted do
      as_user { @connection.exec_insert_all("INSERT INTO console1984_sessions (reason) VALUES ('x')", "x") }
    end

    assert_equal :executed, as_user { @connection.exec_insert_all("INSERT INTO people (name) VALUES ('x')", "x") }
  end

  private
    def as_user(&block)
      Console1984.command_executor.run_as_user(&block)
    end
end
