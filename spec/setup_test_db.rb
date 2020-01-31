# All the below is essentially copied from inst-jobs spec_helper.rb,
# to create the test db, run migrations, etc
ENV['TEST_ENV_NUMBER'] ||= '1'
ENV['TEST_DB_HOST'] ||= 'localhost'
ENV['TEST_DB_DATABASE'] ||= "inst-jobs-test-#{ENV['TEST_ENV_NUMBER']}"
ENV['TEST_REDIS_CONNECTION'] ||= 'redis://localhost:6379/'

Delayed::Backend::Redis::Job.redis = Redis.new(url: ENV['TEST_REDIS_CONNECTION'])
Delayed::Backend::Redis::Job.redis.select ENV['TEST_ENV_NUMBER']

connection_config = {
  adapter: :postgresql,
  host: ENV['TEST_DB_HOST'].presence,
  encoding: 'utf8',
  username: ENV['TEST_DB_USERNAME'],
  database: ENV['TEST_DB_DATABASE']
}

if ::Rails.version < '5'
  class ActiveRecord::Migration
    class << self
      def [](_version); self; end
    end
  end
end

# create the test db if it does not exist, to help out wwtd
ActiveRecord::Base.establish_connection(connection_config.merge(database: 'postgres'))
begin
  ActiveRecord::Base.connection.create_database(connection_config[:database])
rescue ActiveRecord::StatementInvalid
end
ActiveRecord::Base.establish_connection(connection_config)
# TODO reset db and migrate again, to test migrations

# Apply the migrations from the inst-jobs gem
inst_jobs_spec = Gem::Specification.find_by_name('inst-jobs')
if ::Rails.version >= '6'
  sm = ActiveRecord::Base.connection.schema_migration
  migrations = ActiveRecord::MigrationContext.new(inst_jobs_spec.gem_dir + '/db/migrate', sm).migrations
  ActiveRecord::Migrator.new(:up, migrations, sm).migrate
  migrations = ActiveRecord::MigrationContext.new(inst_jobs_spec.gem_dir + '/spec/migrate', sm).migrations
  ActiveRecord::Migrator.new(:up, migrations, sm).migrate
else
  ActiveRecord::Migrator.migrate(inst_jobs_spec.gem_dir + '/db/migrate')
  ActiveRecord::Migrator.migrate(inst_jobs_spec.gem_dir + '/spec/migrate')
end
Delayed::Backend::ActiveRecord::Job.reset_column_information
Delayed::Backend::ActiveRecord::Job::Failed.reset_column_information
