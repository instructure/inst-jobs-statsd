module InstJobsStatsd
  module Stats
    module Timing
      def self.report_timing(stat, job: nil, timing: nil, sample_rate: 1)
        stats = Naming.qualified_names(stat, job)

        if block_given?
          InstStatsd::Statsd.time(stats, sample_rate, short_stat: stat, tags: Naming.dd_job_tags(job)) { yield }
        else
          InstStatsd::Statsd.timing(stats, timing, sample_rate, tags: Naming.dd_job_tags(job))
        end
      end

      def self.report_job_timing_queued(job)
        return unless job
        time_in_queue = ((Delayed::Job.db_time_now - job.run_at) * 1000).round
        report_timing(:queue, job: job, timing: time_in_queue)
      end

      def self.report_job_timing_failed(job)
        return unless job
        time_to_failure = ((Delayed::Job.db_time_now - job.run_at) * 1000).round
        report_timing(:failed_after, job: job, timing: time_to_failure)
      end
    end
  end
end
