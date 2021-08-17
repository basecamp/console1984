module Console1984
  class Session < Base
    include Incineratable

    belongs_to :user
    has_many :commands, dependent: :destroy
    has_many :sensitive_accesses, dependent: :destroy

    def sensitive?
      sensitive_accesses.any?
    end
  end
end

ActiveSupport.run_load_hooks(:console_1984_session, Console1984::Session)
