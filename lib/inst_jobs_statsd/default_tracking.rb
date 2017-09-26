# Defines InstStatsd::DefaultTracking.track_jobs
# to be consistent with InstStatsd::DefaultTracking.track_sql etc
module InstJobsStatsd
  module DefaultTracking
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def track_jobs
        @jobs_tracker ||= JobsTracker.new
      end
    end
  end
end
