# frozen_string_literal: true

RSpec.describe InstStatsd::DefaultTracking do
  it "includes methods defined in the base gem" do
    expect(described_class).to respond_to(:track_sql)
  end

  describe "track_job_stats" do
    it "defines :track_jobs" do
      expect(described_class).to respond_to(:track_jobs)
    end

    it "only does it once" do
      expect(InstJobsStatsd::JobsTracker).to receive(:new).once.and_call_original
      2.times { described_class.track_jobs }
    end
  end
end
