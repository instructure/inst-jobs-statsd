module InstJobsStatsd
  module Stats
    module Counters
      module Failed
        def self.enable
          enable_failed_count
        end

        def self.enable_failed_count
          return if Delayed::Job::Failed < AfterCreateHook
          Delayed::Job::Failed.include AfterCreateHook
        end

        module AfterCreateHook
          def self.included(base)
            base.after_create do
              InstJobsStatsd::Stats::Counters::Failed.report_failed_count(self)
            end
          end
        end

        def self.report_failed_count(job)
          Counters.report_count(:failed, 1, job: job)
        end
      end
    end
  end
end
