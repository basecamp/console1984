module Console1984::ProtectedContext
  # Protect the code to show inspected objects too. This method is invoked
  # for showing returned objects in the console
  def inspect_last_value
    Console1984.supervisor.execute do
      super
    end
  end

  def evaluate(line, line_no, exception: nil)
    Console1984.supervisor.execute_supervised(Array(line)) do
      super
    end
  end
end
