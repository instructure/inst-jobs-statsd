# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Periodic::Run do
  before do
    InstJobsStatsd::Stats::Periodic.instance_variable_set(:@instance, nil)
  end

  describe ".enable" do
    it "enables all the things" do
      expect(described_class).to receive(:enable_run_depth)
      expect(described_class).to receive(:enable_run_age)
      described_class.enable
    end
  end

  describe ".report_run_depth" do
    let(:x) { Struct.new(:perform).new(true) }
    let(:now) { Delayed::Job.db_time_now }

    before do
      described_class.enable_run_depth

      x.delay.perform
      x.delay.perform
      Delayed::Job.first.update(locked_at: Delayed::Job.db_time_now, locked_by: "test")
      x.delay(queue: "queue2").perform
      x.delay(queue: "queue2").perform
      Delayed::Job.last.update(locked_at: Delayed::Job.db_time_now, locked_by: "test")
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.run_depth\.total$/), 2, 1, short_stat: anything, tags: {})
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.run_depth$/), 1, 1, short_stat: anything, tags: { queue: "queue" })
      expect(InstStatsd::Statsd).to receive(:gauge)
        .with(array_including(/\.run_depth$/), 1, 1, short_stat: anything, tags: { queue: "queue2" })
      described_class.report_run_depth
    end
  end

  describe ".report_run_age" do
    let(:x) { Struct.new(:perform).new(true) }
    let(:now) { Delayed::Job.db_time_now }

    before do
      described_class.enable_run_age

      x.delay.perform
      x.delay.perform
      Delayed::Job.first.update(locked_at: now, locked_by: "test")
    end

    it do
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.run_age_total$/), be_within(0.5).of(0), 1, short_stat: anything, tags: { queue: "queue" })
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.run_age_total\.total$/), be_within(0.5).of(0), 1, short_stat: anything, tags: {})
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.run_age_max$/), be_within(0.5).of(0), 1, short_stat: anything, tags: { queue: "queue" })
      expect(InstStatsd::Statsd).to receive(:gauge)
        .ordered.with(array_including(/\.run_age_max\.total$/), be_within(0.5).of(0), 1, short_stat: anything, tags: {})
      described_class.report_run_age
    end

    context "with no running jobs" do
      before do
        Delayed::Job.update_all(locked_at: nil, locked_by: nil)
      end

      it do
        expect(InstStatsd::Statsd).to receive(:gauge)
          .ordered.with(array_including(/\.run_age_total\.total$/), 0, 1, short_stat: anything, tags: {})
        expect(InstStatsd::Statsd).to receive(:gauge)
          .ordered.with(array_including(/\.run_age_max\.total$/), 0, 1, short_stat: anything, tags: {})
        Timecop.freeze(2.minutes.from_now) do
          described_class.report_run_age
        end
      end
    end
  end
end
