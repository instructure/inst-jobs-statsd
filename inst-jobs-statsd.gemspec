lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require 'inst_jobs_statsd/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'inst-jobs-statsd'
  s.version     = InstJobsStatsd::VERSION
  s.authors     = ['Jeremy Slade']
  s.email       = ['jslade@instructure.com']

  s.summary     = 'Stats reporting for inst-jobs'
  s.homepage    = 'https://github.com/instructure/inst-jobs-statsd'
  s.license     = 'MIT'

  s.files = Dir['{lib}/**/*']
  s.test_files = Dir['spec/**/*']

  s.required_ruby_version = '>= 2.3'

  s.add_dependency 'inst-jobs', '>= 0.13', '< 0.16'
  s.add_dependency 'inst_statsd', '~> 2.0'

  s.add_development_dependency 'bump'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'database_cleaner', '1.6.1'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'pg', '0.21.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '3.4.0'
  s.add_development_dependency 'rubocop', '~> 0'
  s.add_development_dependency 'simplecov', '~> 0.14'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'wwtd', '~> 1.3.0'
end
