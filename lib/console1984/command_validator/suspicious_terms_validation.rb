class Console1984::CommandValidator::SuspiciousTermsValidation
  include Console1984::Freezeable

  def initialize(suspicious_terms)
    @suspicious_terms = suspicious_terms
  end

  def validate(parsed_command)
    if contains_suspicious_term?(parsed_command)
      raise Console1984::Errors::SuspiciousCommand
    end
  end

  private
    def contains_suspicious_term?(parsed_command)
      @suspicious_terms.find do |term|
        parsed_command.raw_command.include?(term)
      end
    end
end
