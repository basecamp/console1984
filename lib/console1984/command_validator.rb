class Console1984::CommandValidator
  include Console1984::Freezeable

  def initialize
    @validations_by_name = HashWithIndifferentAccess.new
  end

  class << self
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

  def add_validation(name, validation)
    validations_by_name[name] = validation
  end

  def validate(command)
    parsed_command = ParsedCommand.new(command)

    validations_by_name.values.each do |validation|
      validation.validate(parsed_command)
    end
  end

  def validation_for_name(name)
    validations_by_name[name]
  end

  private
    attr_reader :validations_by_name
end
