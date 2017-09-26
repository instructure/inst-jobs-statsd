module InstJobsStatsd
  module Stats
    module Counters
      def self.report_count(stat, value, job: nil, sample_rate: 1)
        stats = Naming.qualified_names(stat, job)
        InstStatsd::Statsd.count(stats, value, sample_rate)
      end
    end
  end
end
