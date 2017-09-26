RSpec.describe InstJobsStatsd::Stats::Periodic::Failed do
  before do
    InstJobsStatsd::Stats::Periodic.instance_variable_set(:@instance, nil)
  end

  describe '.enable' do
    it 'enables all the things' do
      expect(InstJobsStatsd::Stats::Periodic::Failed).to receive(:enable_failed_depth)
      InstJobsStatsd::Stats::Periodic::Failed.enable
    end
  end

  describe '.report_failed_depth' do
    let(:x) { Struct.new(:perform).new(true) }
    let(:now) { Delayed::Job.db_time_now }

    before do
      InstJobsStatsd::Stats::Periodic.enable_callbacks
      InstJobsStatsd::Stats::Periodic::Failed.enable_failed_depth

      x.send_later(:perform)
      Delayed::Job.first.fail!
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.failed_depth$/), 1, 1)
      InstJobsStatsd::Stats::Periodic::Failed.report_failed_depth
    end
  end
end
