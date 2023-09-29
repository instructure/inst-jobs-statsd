# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Counters::Run do
  describe ".enable" do
    it "enables all the things" do
      expect(InstJobsStatsd::Stats::Counters::Run).to receive(:enable_run_count)
      InstJobsStatsd::Stats::Counters::Run.enable
    end
  end

  describe ".report_run_count" do
    let(:x) { Struct.new(:perform).new(true) }

    before do
      Delayed::Worker.lifecycle.reset!
      InstJobsStatsd::Stats::Counters::Run.enable

      2.times { x.delay.perform }
    end

    it do
      expect(InstStatsd::Statsd).to receive(:count)
        .twice.with(array_including(/\.run$/), 1, 1, short_stat: anything, tags: { priority: Delayed::NORMAL_PRIORITY })
      Delayed::Job.find_each do |job|
        Delayed::Worker.lifecycle.run_callbacks(:perform, {}, job) { nil }
      end
    end
  end
end
