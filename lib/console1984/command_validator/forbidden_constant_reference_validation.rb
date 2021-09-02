class Console1984::CommandValidator::ForbiddenConstantReferenceValidation
  include Console1984::Freezeable

  def initialize(supervisor = Console1984.supervisor, config)
    # We make supervisor an injectable dependency for testing purposes. Everything is frozen
    # for security purposes, so stubbing won't work.
    @supervisor = supervisor

    @forbidden_constants_names = config[:always] || []
    @constant_names_forbidden_in_protected_mode = config[:protected] || []
  end

  def validate(parsed_command)
    if contains_invalid_const_reference?(parsed_command, @forbidden_constants_names) ||
      (@supervisor.protected_mode? && contains_invalid_const_reference?(parsed_command, @constant_names_forbidden_in_protected_mode))
      raise Console1984::Errors::ForbiddenCommand
    end
  end

  private
    def contains_invalid_const_reference?(parsed_command, banned_constants)
      parsed_command.constants.find do |constant_name|
        banned_constants.find { |banned_constant| constant_name.start_with?(banned_constant.to_s) }
      end
    end
end
