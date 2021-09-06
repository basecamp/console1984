# Validates console commands.
#
# This performs an static analysis of console commands. The analysis is meant to happen
# *before* commands are executed, so that they can prevent the execution if needed.
#
# The validation itself happens as a chain of validation objects. The system will invoke
# each validation in order. Validations will raise an error if the validation fails (typically
# a Console1984::Errors::ForbiddenCommandAttempted or Console1984::Errors::SuspiciousCommands).
#
# Internally, validations will receive a Console1984::CommandValidator::ParsedCommand object. This
# exposes parsed constructs in addition to the raw strings so that validations can use those.
#
# There is a convenience method .from_config that lets you instantiate a validation setup from
# a config hash (e.g to customize validations via YAML).
#
# See +config/command_protections.yml+ and the validations in +lib/console1984/command_validator+.
class Console1984::CommandValidator
  include Console1984::Freezeable

  def initialize
    @validations_by_name = HashWithIndifferentAccess.new
  end

  class << self
    # Instantiates a command validator that will configure the validations based on the config passed.
    #
    # For each key in +config+, it will derive the class Console1984::CommandValidator::#{key.camelize}Validation
    # and will instantiate the validation passed the values as params.
    #
    # For example for this config:
    #
    #    { forbidden_reopening: [ActiveRecord, Console1984] }
    #
    # It will instantiate Console1984::CommandValidator::ForbiddenReopeningValidation passing
    # +["ActiveRecord", "Console1984"]+ in the constructor.
    #
    # # See +config/command_protections.yml+ as an example.
    def from_config(config)
      Console1984::CommandValidator.new.tap do |validator|
        config.each do |validator_name, validator_config|
          validator_class = "Console1984::CommandValidator::#{validator_name.to_s.camelize}Validation".constantize
          validator_config.try(:symbolize_keys!)
          validator.add_validation validator_name, validator_class.new(validator_config)
        end
      end
    end
  end

  # Adds a +validation+ to the chain indexed by the provided +name+
  #
  # Validations are executed in the order they are added.
  def add_validation(name, validation)
    validations_by_name[name] = validation
  end

  # Executes the chain of validations passing a {parsed command}[rdoc-ref:Console1984::CommandValidator::ParsedCommand]
  # created with the +command+ string passed by parameter.
  #
  # The validations are executed in the order they were added. If one validation raises an error, the error will
  # raise and the rest of validations won't get checked.
  def validate(command)
    parsed_command = ParsedCommand.new(command)

    validations_by_name.values.each do |validation|
      validation.validate(parsed_command)
    end
  end

  private
    attr_reader :validations_by_name
end
