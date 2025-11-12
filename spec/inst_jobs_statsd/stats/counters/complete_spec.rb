# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Counters::Complete do
  describe ".enable" do
    it "enables all the things" do
      expect(described_class).to receive(:enable_complete_count)
      described_class.enable
    end
  end

  describe ".report_complete_count" do
    let(:x) { Struct.new(:perform).new(true) }

    before do
      Delayed::Worker.lifecycle.reset!
      described_class.enable

      2.times { x.delay.perform }
    end

    it "increments the counter" do
      expect(InstStatsd::Statsd).to receive(:count)
        .twice.with(array_including(/\.complete$/),
                    1,
                    1,
                    short_stat: anything,
                    tags: { priority: Delayed::NORMAL_PRIORITY })
      Delayed::Job.find_each do |job|
        Delayed::Worker.lifecycle.run_callbacks(:perform, {}, job) { nil }
      end
    end
  end
end
