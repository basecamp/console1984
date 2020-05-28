module Console1984::Messages
  PRODUCTION_DATA_WARNING = <<~TXT
    This environment contains production data. The commands you type will be audited.
    
    Willful, unauthorized access carries the penalty of termination or prosecution.
  TXT

  ENTER_UNPROTECTED_ENCRYPTION_MODE_WARNING = <<~TXT
  You have enabled access to encrypted information. This access will be flagged and subject to special auditing.

  You can go back to the protected mode with 'encrypt!'
  TXT

  ENTER_PROTECTED_MODE_WARNING = <<~TXT
  You have disabled access to encrypted information
  TXT
end
