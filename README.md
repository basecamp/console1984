# Console1984

A Rails Console that audits commands and protects users privacy.

> “If you want to keep a secret, you must also hide it from yourself.”
> 
> ― George Orwell, 1984

## Usage

Add this line to your application's Gemfile:

```ruby
gem 'console1984'
```

By default, `console1984` will only work in `production`. [You can configure other environments](#protected-environments). 

## Features

### Auditing

The console will ask for a reason for the console session, identifying the user via the environment
variable `CONSOLE_USER`.

After that, every command the user types will be captured and logged. `console1984` uses
[`rails-structured-logggin`](https://github.com/basecamp/rails-structured-logging) to form
a JSON entry that looks like this:

```json
{
  "@timestamp": "2020-05-15T15:05:45.845642+02:00",
  "ecs": {
    "version": "1.2.0"
  },
  "event": {
    "action": "console.audit_trail",
    "duration": {
      "ms": 0.01
    }
  },
  "console": {
    "user": "Jorge",
    "reason": "fix something",
    "statements": "Account.first\n"
  },
  "rails": {
    "application": "haystack",
    "env": "beta"
  },
  "ruby": {
    "allocations": {
      "count": 0
    }
  },
  "process": {
    "pid": 8539,
    "name": "rails_console",
    "working_directory": "/Users/jorge/Work/basecamp/haystack"
  },
  "performance": {
    "time": {
      "cpu": {
        "ms": 0.01
      },
      "idle": {
        "ms": 0.0
      }
    }
  },
  "original": "  Account Load (1.0ms)  SELECT `accounts`.* FROM `accounts` ORDER BY `accounts`.`id` ASC LIMIT 1\n"
}
```

## Configuration

### Protected environments

<a name="protected-environments"></a>

By default, `console1984` will only be enabled in `production`. You can configure the target environments with
`config.console1984.protected_environments`:

```ruby
config.console1984.protected_environments = %i[ staging production ]
```

### Audit logger

By default, the console will output JSON entries for audit trails to STDOUT. You can configure the
used logger with `config.console1984.audit_logger`: 

```ruby
config.console1984.audit_logger = ActiveSupport::Logger.new("log/console.txt")
```
