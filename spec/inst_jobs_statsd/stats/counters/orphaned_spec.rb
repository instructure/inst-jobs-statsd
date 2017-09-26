RSpec.describe InstJobsStatsd::Stats::Counters::Orphaned do
  describe '.enable' do
    it 'enables all the things' do
      expect(InstJobsStatsd::Stats::Counters::Orphaned).to receive(:enable_orphaned_count)
      InstJobsStatsd::Stats::Counters::Orphaned.enable
    end
  end

  describe '.report_orphaned_count' do
    let(:x) { Struct.new(:perform).new(true) }

    before do
      Delayed::Worker.lifecycle.reset!
      InstJobsStatsd::Stats::Counters::Orphaned.enable

      4.times { x.send_later(:perform) }
      Delayed::Job.order(:id).limit(3)
                  .update_all(locked_by: 'test', locked_at: Delayed::Job.db_time_now)
    end

    it do
      expect(InstStatsd::Statsd).to receive(:count)
        .with(array_including(/\.orphaned$/), 2, 1)
      Delayed::Worker.lifecycle.run_callbacks(:perform, nil, Delayed::Job.first) {}
    end
  end
end
