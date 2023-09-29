# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Timing::Failed do
  let(:worker) { build(:worker) }
  let(:job) { build(:job, run_at: 1.minute.ago) }

  before { Delayed::Worker.lifecycle.reset! }

  describe ".enable" do
    it "enables all the things" do
      expect(InstJobsStatsd::Stats::Timing::Failed).to receive(:enable_failure_timing)
      InstJobsStatsd::Stats::Timing::Failed.enable
    end
  end

  describe ".enable_failure_timing" do
    it "reports failure time" do
      expect(InstStatsd::Statsd).to receive(:timing)
        .once.with(array_including(/\.failed_after$/), any_args)
      InstJobsStatsd::Stats::Timing::Failed.enable_failure_timing
      Delayed::Worker.lifecycle.run_callbacks(
        :error, worker, job, Exception.new("test")
      ) { @in_block = true }
      expect(@in_block).to be_truthy
    end
  end
end
