module Console1984
  class Session < Base
    include Auditable, Incineratable

    belongs_to :user
    has_many :commands, dependent: :destroy
    has_many :sensitive_accesses, dependent: :destroy

    def sensitive?
      sensitive_accesses.any?
    end

    # Loops through all the session commands in order, yielding lists grouped by
    # its sensitive access record, or its absence
    def each_batch_of_commands_grouped_by_sensitive_access
      group = []
      current_sensitive_access = nil
      commands.includes(:sensitive_access).sorted_chronologically.each.with_index do |command, index|
        group << command

        if index > 0 && command.sensitive_access != current_sensitive_access
          yield current_sensitive_access, group
          group = []
          current_sensitive_access = command.sensitive_access
        end
      end

      if group.present?
        yield current_sensitive_access, group
      end
    end
  end
end
