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
          # count = Delayed::Job.jobs_count(:current)  <-- includes running / locked
          scope = queued_jobs_scope
          count = scope.count
          Periodic.report_gauge(:queue_depth, count)
        end

        # Limit the jobs included in this gauge to prevent blowing up
        # memory usage in iterating the list.
        # This has the adverse effect of artificially capping this
        # metric, but the limit should be high enough so that the
        # the metric still has a meaningful range -- and even if
        # the count is capped, the metric will continue to grow
        # if the queue is actually stalled
        def self.report_queue_age
          jobs_run_at = queued_jobs_scope.limit(10_000).pluck(:run_at)
          age_secs = jobs_run_at.map { |t| Delayed::Job.db_time_now - t }
          Periodic.report_gauge(:queue_age_total, age_secs.sum)
          Periodic.report_gauge(:queue_age_max, age_secs.max)
        end

        def self.queued_jobs_scope
          Delayed::Job
            .current
            .where("locked_at IS NULL OR locked_by = 'on_hold'") # not running
        end
      end
    end
  end
end
