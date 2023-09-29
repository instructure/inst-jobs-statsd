# frozen_string_literal: true

require_relative "lib/inst_jobs_statsd/version"

Gem::Specification.new do |s|
  s.name        = "inst-jobs-statsd"
  s.version     = InstJobsStatsd::VERSION
  s.authors     = ["Jeremy Slade"]
  s.email       = ["jslade@instructure.com"]

  s.summary     = "Stats reporting for inst-jobs"
  s.homepage    = "https://github.com/instructure/inst-jobs-statsd"
  s.license     = "MIT"
  s.metadata["rubygems_mfa_required"] = "true"

  s.files = Dir["{lib}/**/*"]

  s.required_ruby_version = ">= 2.7"

  s.add_dependency "inst-jobs", ">= 3.1.1", "< 4.0"
  s.add_dependency "inst_statsd", "~> 3.0"

  s.add_development_dependency "bump"
  s.add_development_dependency "bundler"
  s.add_development_dependency "database_cleaner", "~> 2.0"
  s.add_development_dependency "debug"
  s.add_development_dependency "factory_bot"
  s.add_development_dependency "pg", "~> 1.2"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.9"
  s.add_development_dependency "rubocop-factory_bot", "~> 2.24"
  s.add_development_dependency "rubocop-inst", "~> 1.0"
  s.add_development_dependency "rubocop-rails", "~> 2.21"
  s.add_development_dependency "rubocop-rake", "~> 0.6"
  s.add_development_dependency "rubocop-rspec", "~> 2.24"
  s.add_development_dependency "simplecov", "~> 0.17"
  s.add_development_dependency "timecop"
  s.add_development_dependency "wwtd", "~> 1.4.0"
end
