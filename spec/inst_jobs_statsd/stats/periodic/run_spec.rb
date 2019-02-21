RSpec.describe InstJobsStatsd::Stats::Periodic::Run do
  before do
    InstJobsStatsd::Stats::Periodic.instance_variable_set(:@instance, nil)
  end

  describe '.enable' do
    it 'enables all the things' do
      expect(InstJobsStatsd::Stats::Periodic::Run).to receive(:enable_run_depth)
      expect(InstJobsStatsd::Stats::Periodic::Run).to receive(:enable_run_age)
      InstJobsStatsd::Stats::Periodic::Run.enable
    end
  end

  describe '.report_run_depth' do
    let(:x) { Struct.new(:perform).new(true) }
    let(:now) { Delayed::Job.db_time_now }

    before do
      InstJobsStatsd::Stats::Periodic::Run.enable_run_depth

      x.send_later(:perform)
      x.send_later(:perform)
      Delayed::Job.first.update(locked_at: Delayed::Job.db_time_now, locked_by: 'test')
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.run_depth$/), 1, 1, { tags: {} })
      InstJobsStatsd::Stats::Periodic::Run.report_run_depth
    end
  end

  describe '.report_run_age' do
    let(:x) { Struct.new(:perform).new(true) }
    let(:now) { Delayed::Job.db_time_now }

    before do
      InstJobsStatsd::Stats::Periodic::Run.enable_run_age

      x.send_later(:perform)
      x.send_later(:perform)
      Delayed::Job.first.update(locked_at: now, locked_by: 'test')
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.run_age_total$/), number_near(0), 1, { tags: {} })
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.run_age_max$/), number_near(0), 1, { tags: {} })
      InstJobsStatsd::Stats::Periodic::Run.report_run_age
    end
  end
end
