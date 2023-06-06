module Console1984::InputOutput
  include Console1984::Freezeable, Console1984::Messages

  private
    def show_welcome_message
      show_production_data_warning
      show_commands
    end

    def show_production_data_warning
      show_warning Console1984.production_data_warning
    end

    def ask_for_session_reason
      ask_for_value("#{current_username}, why are you using this console today?")
    end

    def show_commands
      puts <<~TXT

      Commands:

      #{COMMANDS.collect { |command, help_line| "* #{Rainbow(command.to_s).blue}: #{help_line}" }.join("\n")}

      TXT
    end

    def show_warning(message)
      puts Rainbow("\n#{message}\n").yellow
    end

    def ask_for_value(message)
      puts Rainbow("#{message}").green
      reason = $stdin.gets.strip until reason.present?
      reason
    end
end
