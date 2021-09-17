# Extends +Module+ to prevent invoking class_eval in user commands.
#
# We don't use the built-in configurable system from protections.yml because we use
# class_eval ourselves to implement it!
module Console1984::Ext::Core::Module
  extend ActiveSupport::Concern

  def instance_eval(*)
    if Console1984.command_executor.from_irb?(caller)
      raise Console1984::Errors::ForbiddenCommandAttempted
    else
      super
    end
  end

  def method_added(method)
    if Console1984.command_executor.from_irb?(caller) && banned_for_reopening?
      raise Console1984::Errors::ForbiddenCommandExecuted, "Trying to add method `#{method}` to #{self.name}"
    end
  end

  private
    def banned_for_reopening?
      classes_and_modules_banned_for_reopening.find do |banned_class_or_module_name|
        "#{self.name}::".start_with?("#{banned_class_or_module_name}::")
      end
    end

    def classes_and_modules_banned_for_reopening
      @classes_and_modules_banned_for_reopening ||= Console1984.protections_config.validations[:forbidden_reopening]
    end
end
