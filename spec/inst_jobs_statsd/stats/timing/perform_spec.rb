# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Timing::Perform do
  let(:worker) { build(:worker) }
  let(:job) { build(:job, run_at: 1.minute.ago) }

  before { Delayed::Worker.lifecycle.reset! }

  describe ".enable" do
    it "enables all the things" do
      expect(described_class).to receive(:enable_batching)
      expect(described_class).to receive(:enable_perform_timing)
      described_class.enable
    end
  end

  describe ".enable_batching" do
    it "does batching" do
      expect(InstStatsd::Statsd).to receive(:batch).and_call_original
      described_class.enable_batching
      Delayed::Worker.lifecycle.run_callbacks(:perform, worker, job) { @in_block = true }
      expect(@in_block).to be_truthy
    end
  end

  describe ".enable_perform_timing" do
    it "reports queu and perform time" do
      expect(InstStatsd::Statsd).to receive(:timing)
        .once.ordered.with(array_including(/\.queue$/), any_args)
      expect(InstStatsd::Statsd).to receive(:timing)
        .once.ordered.with(array_including(/\.perform$/), any_args)
      described_class.enable_perform_timing
      Delayed::Worker.lifecycle.run_callbacks(:perform, worker, job) { @in_block = true }
      expect(@in_block).to be_truthy
    end
  end
end
