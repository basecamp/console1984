class Console1984::Supervisor::Accesses::Unprotected
  def execute(&block)
    block.call
  end
end
