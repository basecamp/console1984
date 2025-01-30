# Extends IRB execution contexts to hijack execution attempts and
# pass them through Console1984.
module Console1984::Ext::Irb::Context
  include Console1984::Freezeable

  # This method is invoked for showing returned objects in the console
  # Overridden to make sure their evaluation is supervised.
  def inspect_last_value(...)
    Console1984.command_executor.execute_in_protected_mode do
      super
    end
  end

  #
  def evaluate(line_or_statement, ...)
    # irb  < 1.13 passes String as parameter
    # irb >= 1.13 passes IRB::Statement instead and method #code contains the actual code
    code = if defined?(IRB::Statement) && line_or_statement.kind_of?(IRB::Statement)
      line_or_statement.code
    else
      line_or_statement
    end

    Console1984.command_executor.execute(Array(code)) do
      super
    end
  end
end
