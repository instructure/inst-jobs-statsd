RSpec.describe InstJobsStatsd::Stats::Counters::Failed do
  describe '.enable' do
    it 'enables all the things' do
      expect(InstJobsStatsd::Stats::Counters::Failed).to receive(:enable_failed_count)
      InstJobsStatsd::Stats::Counters::Failed.enable
    end
  end

  describe '.report_failed_count' do
    let(:x) { Struct.new(:perform).new(true) }
    it do
      expect(InstStatsd::Statsd).to receive(:count)
        .with(array_including(/\.failed$/), 1, 1)

      InstJobsStatsd::Stats::Counters::Failed.enable_failed_count
      x.send_later(:perform)
      Delayed::Job.first.fail!
    end
  end
end
