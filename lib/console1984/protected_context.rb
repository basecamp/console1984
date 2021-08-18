module Console1984::ProtectedContext
  # This method is invoked for showing returned objects in the console
  # Overridden to make sure their evaluation is supervised.
  def inspect_last_value
    Console1984.supervisor.execute do
      super
    end
  end

  #
  def evaluate(line, line_no, exception: nil)
    Console1984.supervisor.execute_supervised(Array(line)) do
      super
    end
  end

  include Console1984::FrozenMethods
end
