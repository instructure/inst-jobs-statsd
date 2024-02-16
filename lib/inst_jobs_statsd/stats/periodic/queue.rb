# frozen_string_literal: true

module InstJobsStatsd
  module Stats
    module Periodic
      module Queue
        def self.enable
          enable_queue_depth
          enable_queue_age
        end

        def self.enable_queue_depth
          Periodic.enable_callbacks
          Periodic.add(-> { report_queue_depth })
        end

        def self.enable_queue_age
          Periodic.enable_callbacks
          Periodic.add(-> { report_queue_age })
        end

        def self.report_queue_depth
          Periodic.report_gauge_by_queue(:queue_depth, queued_jobs_scope.count)
        end

        # Limit the jobs included in this gauge to prevent blowing up
        # memory usage in iterating the list.
        # This has the adverse effect of artificially capping this
        # metric, but the limit should be high enough so that the
        # the metric still has a meaningful range -- and even if
        # the count is capped, the metric will continue to grow
        # if the queue is actually stalled
        def self.report_queue_age
          jobs_run_at_by_queue = queued_jobs_scope.limit(10_000).pluck(:queue, "ARRAY_AGG(run_at)").to_h
          age_secs_by_queue = jobs_run_at_by_queue.transform_values { |v| v.map { |t| Delayed::Job.db_time_now - t } }
          age_max_by_queue = age_secs_by_queue.transform_values(&:max)
          age_total_by_queue = age_secs_by_queue.transform_values(&:sum)

          Periodic.report_gauge_by_queue(:queue_age_total, age_total_by_queue)
          Periodic.report_gauge_by_queue(:queue_age_max, age_max_by_queue)
        end

        def self.queued_jobs_scope
          Delayed::Job
            .current
            .where("locked_at IS NULL OR locked_by = 'on_hold'") # not running
            .group(:queue)
        end
      end
    end
  end
end
