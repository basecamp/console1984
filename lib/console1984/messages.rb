module Console1984::Messages
  DEFAULT_PRODUCTION_DATA_WARNING = <<~TXT

  You have access to production data here. That's a big deal. As part of our promise to keep customer data safe and private, we audit the commands you type here. Let's get started!
  TXT

  DEFAULT_ENTER_UNPROTECTED_ENCRYPTION_MODE_WARNING = <<~TXT
  Ok! You have access to encrypted information now. We pay extra close attention to any commands entered while you have this access. You can go back to protected mode with 'encrypt!'

  WARNING: Make sure you don't save objects that were loaded while in protected mode, as this can result in saving the encrypted texts.
  TXT

  DEFAULT_ENTER_PROTECTED_MODE_WARNING = <<~TXT
  Great! You are back in protected mode. When we audit, we may reach out for a conversation about the commands you entered. What went well? Did you solve the problem without accessing personal data?
  TXT

  COMMANDS = {
      "decrypt!": "enter unprotected mode with access to encrypted information"
  }
end
