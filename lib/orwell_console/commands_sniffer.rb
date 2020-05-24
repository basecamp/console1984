module OrwellConsole::CommandsSniffer
  def  evaluate(context, statements, file = __FILE__, line = __LINE__)
    OrwellConsole.big_brother.supervise_execution_of(Array(statements)) do
      super
    end
  end
end
