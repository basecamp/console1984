class Console1984::AccessReason
  %i[ for_session for_commands for_sensitive_access ].each do |attribute_name|
    attr_reader attribute_name

    define_method "#{attribute_name}=" do |value|
      validate_not_empty(value) if send(attribute_name).present?
      instance_variable_set "@#{attribute_name}", value
    end
  end

  private
    def validate_not_empty(value)
      raise ArgumentError, "Value can't be blank" if value.blank?
    end
end
