require 'inst-jobs'
require 'inst_statsd'

require_relative 'inst_jobs_statsd/version'

require_relative 'inst_jobs_statsd/default_tracking'
require_relative 'inst_jobs_statsd/jobs_tracker'

require_relative 'inst_jobs_statsd/naming'

require_relative 'inst_jobs_statsd/stats/counters'
require_relative 'inst_jobs_statsd/stats/counters/run'

require_relative 'inst_jobs_statsd/stats/periodic'
require_relative 'inst_jobs_statsd/stats/periodic/failed'
require_relative 'inst_jobs_statsd/stats/periodic/queue'
require_relative 'inst_jobs_statsd/stats/periodic/run'

require_relative 'inst_jobs_statsd/stats/timing'
require_relative 'inst_jobs_statsd/stats/timing/failed'
require_relative 'inst_jobs_statsd/stats/timing/perform'
require_relative 'inst_jobs_statsd/stats/timing/pop'
require_relative 'inst_jobs_statsd/ext/job'

::InstStatsd::DefaultTracking.include InstJobsStatsd::DefaultTracking
