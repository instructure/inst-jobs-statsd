RSpec.describe InstJobsStatsd::Stats::Counters::Complete do
  describe '.enable' do
    it 'enables all the things' do
      expect(InstJobsStatsd::Stats::Counters::Complete).to receive(:enable_complete_count)
      InstJobsStatsd::Stats::Counters::Complete.enable
    end
  end

  describe '.report_complete_count' do
    let(:x) { Struct.new(:perform).new(true) }

    before do
      Delayed::Worker.lifecycle.reset!
      InstJobsStatsd::Stats::Counters::Complete.enable

      2.times { x.delay.perform }
    end

    it "increments the counter" do
      expect(InstStatsd::Statsd).to receive(:count)
        .twice.with(array_including(/\.complete$/), 1, 1, short_stat: anything, tags: {})
      Delayed::Job.all.each do |job|
        Delayed::Worker.lifecycle.run_callbacks(:perform, {}, job) {}
      end
    end
  end
end
