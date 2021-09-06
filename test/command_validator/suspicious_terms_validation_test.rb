require "test_helper"

class SuspicipusTermsValidationTest < ActiveSupport::TestCase
  test "raises a SuspiciousCommand error when a suspicious term appears in the command" do
    assert_raise Console1984::Errors::SuspiciousCommandAttempted do
      run_validation <<~RUBY, ["woah"]
        foo = "woah"
      RUBY
    end
  end

  private
    def run_validation(command, suspicious_terms)
      validation = Console1984::CommandValidator::SuspiciousTermsValidation.new(suspicious_terms)

      parsed_command = Console1984::CommandValidator::ParsedCommand.new(command)
      validation.validate parsed_command
    end
end
