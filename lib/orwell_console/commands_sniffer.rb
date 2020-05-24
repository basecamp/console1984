module OrwellConsole::CommandsSniffer
  def  evaluate(context, statements, file = __FILE__, line = __LINE__)
    super
  ensure
    OrwellConsole.big_brother.executed(Array(statements))
  end
end
