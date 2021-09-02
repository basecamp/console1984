module Console1984::ProtectedObject
  extend ActiveSupport::Concern

  include Console1984::Freezeable

  class_methods do
    def const_get(*arguments)
      if Console1984.supervisor.executing_user_command? && arguments.first.to_s =~ /#{classes_with_dynamic_loading_banned.join("|")}/
        raise Console1984::Errors::ForbiddenCommand
      else
        super
      end
    end

    private
      def classes_with_dynamic_loading_banned
        # We want to prevent dynamic loading of constants that can be used to circumvent class overrides.
        # For now, it grabs the list from the validation.
        @classes_with_dynamic_loading_banned ||= Console1984.supervisor.command_validator.validation_for_name(:forbidden_reopening).banned_class_or_module_names
      end
  end
end
