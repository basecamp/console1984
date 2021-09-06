# Validates references to a configured set of constants.
class Console1984::CommandValidator::ForbiddenConstantReferenceValidation
  include Console1984::Freezeable

  # +config+ will be a hash like:
  #
  #    { always: [ Console1984 ], protected: [ PG, Mysql2 ] }
  def initialize(shield = Console1984.shield, config)
    # We make shield an injectable dependency for testing purposes. Everything is frozen
    # for security purposes, so stubbing won't work.
    @shield = shield

    @forbidden_constants_names = config[:always] || []
    @constant_names_forbidden_in_protected_mode = config[:protected] || []
  end

  # Raises a Console1984::Errors::ForbiddenCommandAttempted if a banned constant is referenced.
  def validate(parsed_command)
    if contains_invalid_const_reference?(parsed_command, @forbidden_constants_names) ||
      (@shield.protected_mode? && contains_invalid_const_reference?(parsed_command, @constant_names_forbidden_in_protected_mode))
      raise Console1984::Errors::ForbiddenCommandAttempted
    end
  end

  private
    def contains_invalid_const_reference?(parsed_command, banned_constants)
      (parsed_command.constants + parsed_command.constant_assignments).find do |constant_name|
        banned_constants.find { |banned_constant| "#{constant_name}::".start_with?("#{banned_constant}::") }
      end
    end
end
