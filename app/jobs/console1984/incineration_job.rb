module Console1984
  class IncinerationJob < ActiveJob::Base
    queue_as { Console1984.incineration_queue }

    discard_on ActiveRecord::RecordNotFound

    def self.schedule(session)
      set(wait: Console1984.incinerate_after).perform_later(session)
    end

    def perform(session)
      session.incinerate
    end
  end
end

ActiveSupport.run_load_hooks(:console_1984_incineration_job, Console1984::IncinerationJob)
