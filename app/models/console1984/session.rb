module Console1984
  class Session < Base
    include Incineratable

    belongs_to :user
    has_many :commands, dependent: :destroy
    has_many :sensitive_accesses, dependent: :destroy
    has_many :audits, dependent: :destroy

    scope :sensitive, ->{ joins(:sensitive_accesses) }
    scope :reviewed, ->{ joins(:audits) }
    scope :pending, ->{ where.not(id: reviewed) }

    def sensitive?
      sensitive_accesses.any?
    end

    def executed_code
      commands.sorted_chronologically.collect(&:statements).collect(&:strip).join("\n")
    end
  end
end
