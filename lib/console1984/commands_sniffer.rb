module Console1984::CommandsSniffer
  def  evaluate(context, statements, file = __FILE__, line = __LINE__)
    Console1984.supervisor.execute_supervised(Array(statements)) do
      super
    end
  end
end
