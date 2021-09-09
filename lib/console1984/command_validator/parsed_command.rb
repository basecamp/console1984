# Parses a command string and exposes different constructs to be used by validations.
#
# Internally, it uses the {parser}[https://github.com/whitequark/parser] gem to perform the parsing.
class Console1984::CommandValidator::ParsedCommand
  include Console1984::Freezeable

  attr_reader :raw_command

  delegate :declared_classes_or_modules, :constants, :constant_assignments, to: :command_parser

  def initialize(raw_command)
    @raw_command = Array(raw_command).join("\n")
  end

  private
    def command_parser
      @command_parser ||= Console1984::CommandValidator::CommandParser.new.tap do |processor|
        ast = Parser::CurrentRuby.parse(raw_command)
        processor.process(ast)
      rescue Parser::SyntaxError
        # Fail open with syntax errors
      end
    end
end
