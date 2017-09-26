module InstJobsStatsd
  module Stats
    module Counters
      module Orphaned
        def self.enable
          enable_orphaned_count
        end

        # The idea of the orphaned count: when a job finishes, if there
        # are other jobs locked_by the *same* worker, they must have been
        # orphaned, because they are not going to be picked up and run by
        # the worker -- the work queue is designed to only have one job
        # locked_by a worker at a time.
        # This is based on the symptom seen in AMS-447, where mutliple
        # rows of the jobs table can be (incorrectly) updated by the same
        # query.
        def self.enable_orphaned_count
          Delayed::Worker.lifecycle.before(:perform) do |_worker, job|
            report_orphaned_count(job)
          end
        end

        def self.report_orphaned_count(job)
          scope = Delayed::Job.where(
            'locked_by = ? AND locked_at = ? AND id <> ?',
            job.locked_by, job.locked_at, job.id
          )
          count = scope.count
          Counters.report_count(:orphaned, count, job: job) unless count.zero?
        end
      end
    end
  end
end
