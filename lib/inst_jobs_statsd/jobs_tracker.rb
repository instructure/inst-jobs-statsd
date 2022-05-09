module InstJobsStatsd
  class JobsTracker
    def self.track(enable_periodic_queries: true)
      @current_tracking = new(enable_periodic_queries: enable_periodic_queries)
      yield
      tracking = @current_tracking
      @current_tracking = nil
      tracking
    end

    def initialize(enable_periodic_queries: true)
      Stats::Counters::Create.enable
      Stats::Counters::Run.enable
      Stats::Counters::Complete.enable
      ::Delayed::Job.prepend InstJobsStatsd::Ext::Job

      if enable_periodic_queries
        Stats::Periodic::Failed.enable
        Stats::Periodic::Queue.enable
        Stats::Periodic::Run.enable
      end

      Stats::Timing::Failed.enable
      Stats::Timing::Perform.enable
      Stats::Timing::Pop.enable
    end
  end
end
