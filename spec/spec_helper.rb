# frozen_string_literal: true

if /^2\.7/ =~ RUBY_VERSION && ENV["BUNDLE_GEMFILE"].include?("60.") # Limit coverage to one build
  require "simplecov"

  SimpleCov.start do
    add_filter "lib/inst_jobs_statsd/version.rb"
    add_filter "spec"
    track_files "lib/**/*.rb"
  end
end

require "inst-jobs-statsd"
require "delayed/testing"

require "debug"
require "database_cleaner"
require "factory_bot"
require "pry"
require "timecop"

# No reason to add default sleep time to specs:
Delayed::Settings.sleep_delay         = 0
Delayed::Settings.sleep_delay_stagger = 0

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = %i[should expect]
  end

  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do |example|
    DatabaseCleaner.strategy = (example.metadata[:sinatra] ? :truncation : :transaction)
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  config.order = :random
  Kernel.srand config.seed
end

require_relative "setup_test_db"

Time.zone = "UTC" # rubocop:disable Rails/TimeZoneAssignment
Rails.logger = Logger.new(nil)
