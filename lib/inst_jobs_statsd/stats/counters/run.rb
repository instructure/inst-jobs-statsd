# frozen_string_literal: true

module InstJobsStatsd
  module Stats
    module Counters
      module Run
        def self.enable
          enable_run_count
        end

        def self.enable_run_count
          Delayed::Worker.lifecycle.before(:perform) do |_worker, job|
            report_run_count(job)
          end
        end

        def self.report_run_count(job)
          Counters.report_count(:run, 1, job: job)
        end
      end
    end
  end
end
