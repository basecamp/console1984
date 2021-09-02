class Console1984::CommandValidator::ParsedCommand
  include Console1984::Freezeable

  attr_reader :raw_command

  delegate :declared_classes_or_modules, :constants, to: :processed_ast

  def initialize(raw_command)
    @raw_command = Array(raw_command).join("\n")
  end

  private
    def processed_ast
      @processed_ast ||= CommandProcessor.new.tap do |processor|
        ast = Parser::CurrentRuby.parse(raw_command)
        processor.process(ast)
      rescue Parser::SyntaxError
        # Fail open with syntax errors
      end
    end

    class CommandProcessor < ::Parser::AST::Processor
      include AST::Processor::Mixin

      attr_reader :constants, :declared_classes_or_modules

      def initialize
        @constants = []
        @declared_classes_or_modules = []
      end

      def on_class(node)
        super
        const_declaration, _, _ = *node

        processor = self.class.new
        processor.process(const_declaration)
        @declared_classes_or_modules << processor.constants.first if processor.constants.present?
      end

      alias_method :on_module, :on_class

      def on_const(node)
        super
        name, const_name = *node
        const_name = const_name.to_s
        last_constant = @constants.last

        if name.nil? || (name && name.type == :cbase) # cbase = leading ::
          if last_constant&.end_with?("::")
            last_constant << const_name
          else
            @constants << const_name
          end
        elsif last_constant
          last_constant << "::#{const_name}"
        end
      end
    end
end
