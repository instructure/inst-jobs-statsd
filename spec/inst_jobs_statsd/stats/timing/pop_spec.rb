# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Timing::Pop do
  let(:worker) { build(:worker) }
  let(:job) { build(:job, run_at: 1.minute.ago) }

  before { Delayed::Worker.lifecycle.reset! }

  describe ".enable" do
    it "enables all the things" do
      expect(described_class).to receive(:enable_pop_timing)
      expect(described_class).to receive(:enable_workqueue_pop_timing)
      described_class.enable
    end
  end

  describe ".enable_pop_timing" do
    it "reports pop time" do
      expect(InstStatsd::Statsd).to receive(:timing)
        .once.ordered.with(array_including(/\.pop$/), any_args)
      described_class.enable_pop_timing
      Delayed::Worker.lifecycle.run_callbacks(:pop, worker) { @in_block = true }
      expect(@in_block).to be_truthy
    end
  end

  describe ".enable_workqueue_pop_timing" do
    it "reports pop time" do
      expect(InstStatsd::Statsd).to receive(:timing)
        .once.ordered.with(array_including(/\.workqueuepop$/), any_args)
      described_class.enable_workqueue_pop_timing
      Delayed::Worker.lifecycle.run_callbacks(:work_queue_pop, worker, {}) { @in_block = true }
      expect(@in_block).to be_truthy
    end
  end
end
