# frozen_string_literal: true

module InstJobsStatsd
  module Stats
    module Counters
      module Create
        def self.enable
          enable_create_count
        end

        def self.enable_create_count
          Delayed::Worker.lifecycle.after(:create) do |_, result:|
            report_create_count(result)
          end
        end

        def self.report_create_count(job)
          Counters.report_count(:create, 1, job: job)
        end
      end
    end
  end
end
