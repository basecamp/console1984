# Extends +Module+ to prevent invoking class_eval in user commands.
#
# We don't use the built-in configurable system from protections.yml because we use
# class_eval ourselves to implement it!
module Console1984::Ext::Core::Module
  extend ActiveSupport::Concern

  def instance_eval(*)
    if Console1984.command_executor.executing_user_command?
      raise Console1984::Errors::ForbiddenCommand
    else
      super
    end
  end
end
