# Validates that the command doesn't include a term based on a configured list.
class Console1984::CommandValidator::SuspiciousTermsValidation
  include Console1984::Freezeable

  def initialize(suspicious_terms)
    @suspicious_terms = suspicious_terms
  end

  # Raises a Console1984::Errors::SuspiciousCommand if the term is referenced.
  def validate(parsed_command)
    if contains_suspicious_term?(parsed_command)
      raise Console1984::Errors::SuspiciousCommandAttempted
    end
  end

  private
    def contains_suspicious_term?(parsed_command)
      @suspicious_terms.find do |term|
        parsed_command.raw_command.include?(term)
      end
    end
end
