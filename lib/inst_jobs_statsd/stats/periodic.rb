module InstJobsStatsd
  module Stats
    module Periodic
      def self.enable_callbacks
        @instance ||= Callbacks.new
      end

      def self.add(proc)
        return unless @instance
        @instance.add(proc)
      end

      def self.report_gauge(stat, value, job: nil, sample_rate: 1)
        stats = Naming.qualified_names(stat, job)
        InstStatsd::Statsd.gauge(stats, value, sample_rate, tags: Naming.dd_job_tags(job))
      end

      class Callbacks
        def initialize(min_interval = 60)
          @timer = Timer.new(min_interval)
          @procs = []
          register_lifecycle
        end

        def add(proc)
          @procs << proc if proc
        end

        # This hooks into the lifecycle events such that it will
        # get triggered periodically which reasonable certainty
        # -- as long as the rest of the inst-jobs processing
        # system is working, any way.
        # This allows for stats to be reported periodically
        # without having to start a separate sideband process.
        # It means that reporting of those stats will run
        # inline (in the same process and thread) as the
        # regular job processing work, but it also means
        # no need for an additional database connection, and
        # no managing of additional threads or processes.
        #
        # The :work_queue_pop event is used becaused in production
        # mode, the 'parent_process' work queue is typically
        # going to be used, and this callback runs in the parent
        # process -- as opposed to having this callback run in
        # each of the subordinate worker processes, which would
        # not be ideal. In a dev env with the 'in_process' work queue,
        # there's typically only going to be a single worker process
        # anyway, so it works just as well.
        def register_lifecycle
          Delayed::Worker.lifecycle.after(:work_queue_pop) do |_q, _c|
            @timer.tick do
              run
            end
          end
        end

        def run
          InstStatsd::Statsd.batch do
            @procs.each(&:call)
          end
        end
      end

      class Timer
        def initialize(min_interval)
          @min_interval = min_interval * 1.0
          @start_time = Delayed::Job.db_time_now
          update_next_run
        end

        # This is called as often as possible, based on the lifecycle callbacks.
        # When the required interval of time has passed, execute the given block
        def tick
          return unless Delayed::Job.db_time_now >= @next_run
          update_next_run
          yield
        end

        private

        # Target the next run time to based on the original start time,
        # instead of just adding the run interval, to prevent drift
        # from the target interval as much as possible
        def update_next_run
          ticks = ((Delayed::Job.db_time_now - @start_time) / @min_interval).floor
          @next_run = @start_time + (ticks + 1) * @min_interval
        end
      end
    end
  end
end
