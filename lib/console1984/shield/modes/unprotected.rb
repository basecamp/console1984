# An execution mode that doesn't protect encrypted information or external systems.
class Console1984::Shield::Modes::Unprotected
  include Console1984::Freezeable

  def execute(&block)
    block.call
  end
end
