class Console1984::Shield::Accesses::Unprotected
  include Console1984::Freezeable

  def execute(&block)
    block.call
  end
end
