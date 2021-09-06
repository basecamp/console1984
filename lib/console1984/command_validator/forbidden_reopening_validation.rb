# Validates attempts to reopen classes and modules based on a configured set.
class Console1984::CommandValidator::ForbiddenReopeningValidation
  include Console1984::Freezeable

  attr_reader :banned_class_or_module_names

  def initialize(banned_classes_or_modules)
    @banned_class_or_module_names = banned_classes_or_modules.collect(&:to_s)
  end

  # Raises a Console1984::Errors::ForbiddenCommandAttempted if an banned class or module reopening
  # is detected.
  def validate(parsed_command)
    if contains_invalid_class_or_module_declaration?(parsed_command)
      raise Console1984::Errors::ForbiddenCommandAttempted
    end
  end

  private
    def contains_invalid_class_or_module_declaration?(parsed_command)
      (parsed_command.declared_classes_or_modules + parsed_command.constant_assignments).find { |class_or_module_name| banned?(class_or_module_name) }
    end

    def banned?(class_or_module_name)
      @banned_class_or_module_names.find do |banned_class_or_module_name|
        "#{class_or_module_name}::".start_with?("#{banned_class_or_module_name}::")
      end
    end
end
