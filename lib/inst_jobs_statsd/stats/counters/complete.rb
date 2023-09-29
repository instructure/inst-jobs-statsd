# frozen_string_literal: true

module InstJobsStatsd
  module Stats
    module Counters
      module Complete
        def self.enable
          enable_complete_count
        end

        def self.enable_complete_count
          Delayed::Worker.lifecycle.after(:perform) do |_worker, job|
            report_complete_count(job)
          end
        end

        def self.report_complete_count(job)
          Counters.report_count(:complete, 1, job: job)
        end
      end
    end
  end
end
