class Console1984::Supervisor::Accesses::Unprotected
  include Console1984::Freezeable

  def execute(&block)
    block.call
  end
end
