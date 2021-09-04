# Extends IRB execution contexts to hijack execution attempts and
# pass them through Console1984.
module Console1984::Ext::Irb::Context
  include Console1984::Freezeable

  # This method is invoked for showing returned objects in the console
  # Overridden to make sure their evaluation is supervised.
  def inspect_last_value
    Console1984.command_executor.execute_in_protected_mode do
      super
    end
  end

  #
  def evaluate(line, line_no, exception: nil)
    Console1984.command_executor.execute(Array(line)) do
      super
    end
  end
end
