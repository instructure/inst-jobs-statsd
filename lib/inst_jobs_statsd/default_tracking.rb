# frozen_string_literal: true

# Defines InstStatsd::DefaultTracking.track_jobs
# to be consistent with InstStatsd::DefaultTracking.track_sql etc
module InstJobsStatsd
  module DefaultTracking
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def track_jobs(enable_periodic_queries: true)
        @jobs_tracker ||= JobsTracker.new(enable_periodic_queries: enable_periodic_queries) # rubocop:disable Naming/MemoizedInstanceVariableName
      end
    end
  end
end
