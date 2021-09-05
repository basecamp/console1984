# Prevents invoking a configurable set of methods
class Console1984::Shield::MethodInvocationShell
  include Console1984::Freezeable

  class << self
    def install_for(config)
      Array(config[:user]).each { |invocation| self.new(invocation, only_for_user_commands: true).prevent_methods_invocation }
      Array(config[:system]).each { |invocation| self.new(invocation, only_for_user_commands: false).prevent_methods_invocation }
    end
  end

  attr_reader :class_name, :methods, :only_for_user_commands

  def initialize(invocation, only_for_user_commands:)
    @class_name, methods = invocation.to_a
    @methods = Array(methods)
    @only_for_user_commands = only_for_user_commands
  end

  def prevent_methods_invocation
    class_name.constantize.prepend build_protection_module
  end

  def build_protection_module
    source = protected_method_invocations_source
    Module.new do
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        #{source}
      RUBY
    end
  end

  def protected_method_invocations_source
    methods.collect { |method| protected_method_invocation_source_for(method) }.join("\n")
  end

  def protected_method_invocation_source_for(method)
    <<~RUBY
      def #{method}(*args)
        if (!#{only_for_user_commands} || Console1984.command_executor.executing_user_command?) && caller.find do |line|
            line_from_irb = line =~ /^[^\\/]/
            break if !(line =~ /console1984\\/lib/ || line_from_irb)
            line_from_irb
          end
          raise Console1984::Errors::ForbiddenCommand
        else
          super
        end
      end
    RUBY
  end
end
