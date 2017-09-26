RSpec.describe InstStatsd::DefaultTracking do
  it 'includes methods defined in the base gem' do
    expect(InstStatsd::DefaultTracking.respond_to?(:track_sql)).to be_truthy
  end

  describe 'track_job_stats' do
    it 'defines :track_jobs' do
      expect(InstStatsd::DefaultTracking.respond_to?(:track_jobs)).to be_truthy
    end

    it 'only does it once' do
      expect(InstJobsStatsd::JobsTracker).to receive(:new).once.and_call_original
      2.times { InstStatsd::DefaultTracking.track_jobs }
    end
  end
end
