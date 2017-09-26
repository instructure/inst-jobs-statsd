module InstJobsStatsd
  module Stats
    module Timing
      module Perform
        def self.enable
          enable_batching
          enable_perform_timing
        end

        def self.enable_batching
          Delayed::Worker.lifecycle.around(:perform) do |worker, job, &block|
            InstStatsd::Statsd.batch do
              block.call(worker, job)
            end
          end
        end

        def self.enable_perform_timing
          Delayed::Worker.lifecycle.around(:perform) do |worker, job, &block|
            Timing.report_job_timing_queued(job)
            Timing.report_timing(:perform, job: job) do
              block.call(worker, job)
            end
          end
        end
      end
    end
  end
end
