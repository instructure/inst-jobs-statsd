module InstJobsStatsd
  class JobsTracker
    def self.track
      @current_tracking = new
      yield
      tracking = @current_tracking
      @current_tracking = nil
      tracking
    end

    def initialize
      Stats::Counters::Failed.enable
      Stats::Counters::Orphaned.enable
      Stats::Counters::Run.enable

      Stats::Periodic::Failed.enable
      Stats::Periodic::Queue.enable
      Stats::Periodic::Run.enable

      Stats::Timing::Failed.enable
      Stats::Timing::Perform.enable
      Stats::Timing::Pop.enable
    end
  end
end
