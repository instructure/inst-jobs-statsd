module InstJobsStatsd
  module Stats
    module Timing
      module Failed
        def self.enable
          enable_failure_timing
        end

        def self.enable_failure_timing
          Delayed::Worker.lifecycle.before(:error) do |_worker, job, _exception|
            Timing.report_job_timing_failed(job)
          end
        end
      end
    end
  end
end
