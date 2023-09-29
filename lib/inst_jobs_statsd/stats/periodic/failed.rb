# frozen_string_literal: true

module InstJobsStatsd
  module Stats
    module Periodic
      module Failed
        def self.enable
          enable_failed_depth
        end

        def self.enable_failed_depth
          Periodic.enable_callbacks
          Periodic.add(-> { report_failed_depth })
        end

        def self.report_failed_depth
          count = Delayed::Job::Failed.count
          Periodic.report_gauge(:failed_depth, count)
        end
      end
    end
  end
end
