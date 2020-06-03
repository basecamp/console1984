module Console1984::Supervisor::InputOutput
  def show_warning(message)
    puts ColorizedString.new("\n#{message}\n").yellow
  end

  def ask_for_value(message)
    puts ColorizedString.new("#{message}").green
    reason = $stdin.gets.strip until reason.present?
    reason
  end
end
