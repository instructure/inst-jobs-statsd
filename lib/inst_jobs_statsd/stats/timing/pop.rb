# frozen_string_literal: true

module InstJobsStatsd
  module Stats
    module Timing
      module Pop
        def self.enable
          enable_pop_timing
          enable_workqueue_pop_timing
        end

        def self.enable_pop_timing
          Delayed::Worker.lifecycle.around(:pop) do |worker, &block|
            Timing.report_timing(:pop) do
              block.call(worker)
            end
          end
        end

        def self.enable_workqueue_pop_timing
          Delayed::Worker.lifecycle.around(:work_queue_pop) do |worker, config, &block|
            Timing.report_timing(:workqueuepop) do
              block.call(worker, config)
            end
          end
        end
      end
    end
  end
end
