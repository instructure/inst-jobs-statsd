# frozen_string_literal: true

module InstJobsStatsd
  module Stats
    module Periodic
      module Run
        def self.enable
          enable_run_depth
          enable_run_age
        end

        def self.enable_run_depth
          Periodic.enable_callbacks
          Periodic.add(-> { report_run_depth })
        end

        def self.enable_run_age
          Periodic.enable_callbacks
          Periodic.add(-> { report_run_age })
        end

        def self.report_run_depth
          scope = running_jobs_scope
          Periodic.report_gauge(:run_depth, scope.count)
        end

        def self.report_run_age
          jobs_run_at = running_jobs_scope.limit(10_000).pluck(:run_at)
          age_secs = jobs_run_at.map { |t| Delayed::Job.db_time_now - t }
          Periodic.report_gauge(:run_age_total, age_secs.sum)
          Periodic.report_gauge(:run_age_max, age_secs.max || 0)
        end

        def self.running_jobs_scope
          Delayed::Job.running
        end
      end
    end
  end
end
