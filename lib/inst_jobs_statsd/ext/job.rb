module InstJobsStatsd
  module Ext
    module Job
      def fail!
        failed_job = super
        InstJobsStatsd::Stats::Counters.report_count(:failed, 1, job: failed_job)
        failed_job
      end
    end
  end
end
