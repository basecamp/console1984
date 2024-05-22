require "irb/command"

module Console1984::Commands
  class Decrypt < IRB::Command::Base
    include Console1984::Ext::Irb::Commands

    category "Console1984"
    description "go back to protected mode, without access to encrypted information"

    def execute(*)
      decrypt!
    end
  end
end
