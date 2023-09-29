# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Timing do
  let(:job) { build(:job, run_at: 1.minute.ago) }

  describe "report_tinming" do
    context "with a block" do
      it "reports the elapsed time" do
        expect(InstStatsd::Statsd).to receive(:time)
        InstJobsStatsd::Stats::Timing.report_timing("test", job: job) { sleep 0.001 }
      end
    end

    context "without a block" do
      it "reports the given time" do
        expect(InstStatsd::Statsd).to receive(:timing)
        InstJobsStatsd::Stats::Timing.report_timing("test", job: job, timing: 123)
      end
    end
  end

  describe "report_job_timing_queued" do
    it "reports the stat" do
      expect(InstStatsd::Statsd).to receive(:timing)
        .with(array_including(/\.queue$/), any_args)
      InstJobsStatsd::Stats::Timing.report_job_timing_queued(job)
    end
  end

  describe "report_job_timing_failed" do
    it "reports the stat" do
      expect(InstStatsd::Statsd).to receive(:timing)
        .with(array_including(/\.failed_after$/), any_args)
      InstJobsStatsd::Stats::Timing.report_job_timing_failed(job)
    end
  end
end
