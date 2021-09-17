This directory contain two subdirectories with ruby examples:

- flagged: snippets of ruby code that should be flagged as sensitive when executed in a
  console.
- allowed: snippets of code that should not fail

tampering_protection_test.rb will execute a test for each test case defined in these
directories validating the expectation.