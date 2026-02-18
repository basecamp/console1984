$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'console1984/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'console1984'
  spec.version     = Console1984::VERSION
  spec.authors     = ['Jorge Manrubia']
  spec.email       = ['jorge@basecamp.com']
  spec.homepage    = 'http://github.com/basecamp/console1984'
  spec.summary     = 'Your Rails console, 1984 style'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir.glob(['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md', 'test/fixtures/**/*'], File::FNM_DOTMATCH)

  spec.add_dependency 'rainbow'
  spec.add_dependency 'parser'
  spec.add_dependency 'rails', '>= 7.0'
  spec.add_dependency 'irb', '~> 1.13'

  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rubocop', '>= 1.18.4'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-packaging'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'rubyzip'
  spec.add_development_dependency 'ostruct'
end
