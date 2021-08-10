module Console1984::Session::Incineratable
  extend ActiveSupport::Concern

  included do
    after_create_commit :incinerate_later, if: -> { Console1984.incinerate }
  end

  def incinerate_later
    Console1984::IncinerationJob.schedule self
  end

  def incinerate
    destroy
  end
end
