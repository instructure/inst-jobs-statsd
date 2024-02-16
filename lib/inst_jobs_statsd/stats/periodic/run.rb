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
          Periodic.report_gauge_by_queue(:run_depth, running_jobs_scope.count)
        end

        def self.report_run_age
          jobs_run_at_by_queue = running_jobs_scope.limit(10_000).pluck(:queue, "ARRAY_AGG(run_at)").to_h
          age_secs_by_queue = jobs_run_at_by_queue.transform_values { |v| v.map { |t| Delayed::Job.db_time_now - t } }
          age_max_by_queue = age_secs_by_queue.transform_values(&:max)
          age_total_by_queue = age_secs_by_queue.transform_values(&:sum)

          Periodic.report_gauge_by_queue(:run_age_total, age_total_by_queue)
          Periodic.report_gauge_by_queue(:run_age_max, age_max_by_queue)
        end

        def self.running_jobs_scope
          Delayed::Job.running.group(:queue)
        end
      end
    end
  end
end
