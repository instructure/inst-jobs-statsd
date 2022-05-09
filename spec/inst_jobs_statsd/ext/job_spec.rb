RSpec.describe 'InstJobsStatsd::Ext::Job' do
  describe 'sends count on job failure' do
    before do
      InstJobsStatsd::JobsTracker.new
    end
    let(:x) { Struct.new(:perform).new(true) }
    it 'sends a stat' do
      allow(InstStatsd::Statsd).to receive(:count)

      x.delay.perform
      Delayed::Job.first.fail!

      expect(InstStatsd::Statsd).to have_received(:count)
        .with(array_including(/\.failed$/), 1, 1, short_stat: :failed, tags: {})
    end
  end
end
