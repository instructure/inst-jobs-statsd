# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Periodic::Queue do
  before do
    InstJobsStatsd::Stats::Periodic.instance_variable_set(:@instance, nil)
  end

  describe ".enable" do
    it "enables all the things" do
      expect(InstJobsStatsd::Stats::Periodic::Queue).to receive(:enable_queue_depth)
      expect(InstJobsStatsd::Stats::Periodic::Queue).to receive(:enable_queue_age)
      InstJobsStatsd::Stats::Periodic::Queue.enable
    end
  end

  describe ".report_queue_depth" do
    let(:x) { Struct.new(:perform).new(true) }
    let(:now) { Delayed::Job.db_time_now }

    before do
      InstJobsStatsd::Stats::Periodic::Queue.enable_queue_depth

      x.delay.perform
      Delayed::Job.first.update(locked_at: Delayed::Job.db_time_now, locked_by: "test")

      x.delay.perform
      x.delay(run_at: now + 1.minute).perform
      x.delay(run_at: now + 10.minutes).perform
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.queue_depth$/), 1, 1, short_stat: anything, tags: {})
      InstJobsStatsd::Stats::Periodic::Queue.report_queue_depth
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.queue_depth$/), 2, 1, short_stat: anything, tags: {})
      Timecop.freeze(2.minutes.from_now) do
        InstJobsStatsd::Stats::Periodic::Queue.report_queue_depth
      end
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.queue_depth$/), 3, 1, short_stat: anything, tags: {})
      Timecop.freeze(20.minutes.from_now) do
        InstJobsStatsd::Stats::Periodic::Queue.report_queue_depth
      end
    end
  end

  describe ".report_queue_age" do
    let(:x) { Struct.new(:perform).new(true) }
    let(:now) { Delayed::Job.db_time_now }

    before do
      InstJobsStatsd::Stats::Periodic::Queue.enable_queue_age

      x.delay.perform
      Delayed::Job.first.update(locked_at: Delayed::Job.db_time_now, locked_by: "test")

      x.delay.perform
      x.delay(run_at: now + 1.minute).perform
      x.delay(run_at: now + 10.minutes).perform
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_total$/), be_within(0.5).of(0), 1, short_stat: anything, tags: {})
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_max$/), be_within(0.5).of(0), 1, short_stat: anything, tags: {})
      InstJobsStatsd::Stats::Periodic::Queue.report_queue_age
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_total$/), be_within(0.5).of(180), 1, short_stat: anything, tags: {})
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_max$/), be_within(0.5).of(120), 1, short_stat: anything, tags: {})
      Timecop.freeze(2.minutes.from_now) do
        InstJobsStatsd::Stats::Periodic::Queue.report_queue_age
      end
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_total$/), be_within(0.5).of(2940), 1, short_stat: anything, tags: {})
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.queue_age_max$/), be_within(0.5).of(1200), 1, short_stat: anything, tags: {})
      Timecop.freeze(20.minutes.from_now) do
        InstJobsStatsd::Stats::Periodic::Queue.report_queue_age
      end
    end

    context "with empty queue" do
      before do
        Delayed::Job.delete_all
      end

      it do
        expect(InstStatsd::Statsd).to receive(:gauge)
          .ordered.with(array_including(/\.queue_age_total$/), 0, 1, short_stat: anything, tags: {})
        expect(InstStatsd::Statsd).to receive(:gauge)
          .ordered.with(array_including(/\.queue_age_max$/), 0, 1, short_stat: anything, tags: {})
        Timecop.freeze(2.minutes.from_now) do
          InstJobsStatsd::Stats::Periodic::Queue.report_queue_age
        end
      end
    end
  end
end
