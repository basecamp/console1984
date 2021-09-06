# Prevents invoking a configurable set of methods
class Console1984::Shield::MethodInvocationShell
  include Console1984::Freezeable

  class << self
    def install_for(invocations)
      Array(invocations).each { |invocation| self.new(invocation).prevent_methods_invocation }
    end
  end

  attr_reader :class_name, :methods, :only_for_user_commands

  def initialize(invocation)
    @class_name, methods = invocation.to_a
    @methods = Array(methods)
  end

  def prevent_methods_invocation
    class_name.to_s.constantize.prepend build_protection_module
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
        if Console1984.command_executor.from_irb?(caller)
          raise Console1984::Errors::ForbiddenCommandAttempted
        else
          super
        end
      end
    RUBY
  end
end
