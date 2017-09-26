RSpec.describe InstJobsStatsd::Stats::Periodic::Queue do
  before do
    InstJobsStatsd::Stats::Periodic.instance_variable_set(:@instance, nil)
  end

  describe '.enable' do
    it 'enables all the things' do
      expect(InstJobsStatsd::Stats::Periodic::Queue).to receive(:enable_queue_depth)
      expect(InstJobsStatsd::Stats::Periodic::Queue).to receive(:enable_queue_age)
      InstJobsStatsd::Stats::Periodic::Queue.enable
    end
  end

  describe '.report_queue_depth' do
    let(:x) { Struct.new(:perform).new(true) }
    let(:now) { Delayed::Job.db_time_now }

    before do
      InstJobsStatsd::Stats::Periodic::Queue.enable_queue_depth

      x.send_later(:perform)
      Delayed::Job.first.update(locked_at: Delayed::Job.db_time_now, locked_by: 'test')

      x.send_later(:perform)
      x.send_later_enqueue_args(:perform, run_at: now + 1.minute)
      x.send_later_enqueue_args(:perform, run_at: now + 10.minutes)
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.queue_depth$/), 1, 1)
      InstJobsStatsd::Stats::Periodic::Queue.report_queue_depth
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.queue_depth$/), 2, 1)
      Timecop.freeze(2.minutes.from_now) do
        InstJobsStatsd::Stats::Periodic::Queue.report_queue_depth
      end
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.queue_depth$/), 3, 1)
      Timecop.freeze(20.minutes.from_now) do
        InstJobsStatsd::Stats::Periodic::Queue.report_queue_depth
      end
    end
  end

  describe '.report_queue_age' do
    let(:x) { Struct.new(:perform).new(true) }
    let(:now) { Delayed::Job.db_time_now }

    before do
      InstJobsStatsd::Stats::Periodic::Queue.enable_queue_age

      x.send_later(:perform)
      Delayed::Job.first.update(locked_at: Delayed::Job.db_time_now, locked_by: 'test')

      x.send_later(:perform)
      x.send_later_enqueue_args(:perform, run_at: now + 1.minute)
      x.send_later_enqueue_args(:perform, run_at: now + 10.minutes)
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_total$/), number_near(0), 1)
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_max$/), number_near(0), 1)
      InstJobsStatsd::Stats::Periodic::Queue.report_queue_age
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_total$/), number_near(180), 1)
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_max$/), number_near(120), 1)
      Timecop.freeze(2.minutes.from_now) do
        InstJobsStatsd::Stats::Periodic::Queue.report_queue_age
      end
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_total$/), number_near(2940), 1)
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_max$/), number_near(1200), 1)
      Timecop.freeze(20.minutes.from_now) do
        InstJobsStatsd::Stats::Periodic::Queue.report_queue_age
      end
    end
  end
end
