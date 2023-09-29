# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Timing::Perform do
  let(:worker) { build(:worker) }
  let(:job) { build(:job, run_at: 1.minute.ago) }

  before { Delayed::Worker.lifecycle.reset! }

  describe ".enable" do
    it "enables all the things" do
      expect(InstJobsStatsd::Stats::Timing::Perform).to receive(:enable_batching)
      expect(InstJobsStatsd::Stats::Timing::Perform).to receive(:enable_perform_timing)
      InstJobsStatsd::Stats::Timing::Perform.enable
    end
  end

  describe ".enable_batching" do
    it "does batching" do
      expect(InstStatsd::Statsd).to receive(:batch).and_call_original
      InstJobsStatsd::Stats::Timing::Perform.enable_batching
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
      InstJobsStatsd::Stats::Timing::Perform.enable_perform_timing
      Delayed::Worker.lifecycle.run_callbacks(:perform, worker, job) { @in_block = true }
      expect(@in_block).to be_truthy
    end
  end
end
