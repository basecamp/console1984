module Console1984
  class Session < Base
    include Auditable, Incineratable

    belongs_to :user
    has_many :commands, dependent: :destroy
    has_many :sensitive_accesses, dependent: :destroy

    def sensitive?
      sensitive_accesses.any?
    end

    def executed_code
      commands.sorted_chronologically.collect(&:statements).collect(&:strip).join("\n")
    end
  end
end
