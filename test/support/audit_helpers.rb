module AuditHelpers
  private
    def assert_audit_trail(commands: [], &block)
      assert_difference -> { Console1984::Command.count }, commands.length, &block

      Console1984::Command.last(commands.length).each.with_index do |command, index|
        assert_equal commands[index], command.statements
      end
    end
end
