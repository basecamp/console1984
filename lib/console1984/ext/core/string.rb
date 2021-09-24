# Prevents loading forbidden classes dynamically.
#
# See extension to +Console1984::Ext::Core::Object#const_get+.
module Console1984::Ext::Core::String
  extend ActiveSupport::Concern

  include Console1984::Freezeable
  self.prevent_instance_data_manipulation_after_freezing = false

  def constantize
    if Console1984.command_executor.from_irb?(caller)
      begin
        Console1984.command_executor.validate_command("class #{self}; end")
        super
      rescue Console1984::Errors::ForbiddenCommandAttempted
        raise
      rescue StandardError
        super
      end
    else
      super
    end
  end
end
