module Console1984::Session::Incineratable
  extend ActiveSupport::Concern

  included do
    after_create_commit :incinerate_later, if: -> { Console1984.incinerate }
  end

  def incinerate_later
    Console1984::IncinerationJob.schedule self
  end

  def incinerate
    if incineratable?
      destroy
    else
      raise Console1984::Errors::ForbiddenIncineration,
            "Session #{id} was created at #{created_at.utc}. It shouldn't be deleted"\
            " until #{earliest_possible_incineration_date.utc}, and now it's #{Time.now.utc}"
    end
  end

  private
    def incineratable?
      Time.now >= earliest_possible_incineration_date
    end

    def earliest_possible_incineration_date
      created_at + Console1984.incinerate_after - 1.second
    end
end
