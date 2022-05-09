RSpec.describe InstJobsStatsd::Stats::Counters::Create do
  describe '.enable' do
    it 'enables all the things' do
      expect(InstJobsStatsd::Stats::Counters::Create).to receive(:enable_create_count)
      InstJobsStatsd::Stats::Counters::Create.enable
    end
  end

  describe '.report_create_count' do
    let(:x) { Struct.new(:perform).new(true) }

    before do
      Delayed::Worker.lifecycle.reset!
      InstJobsStatsd::Stats::Counters::Create.enable

      2.times { x.delay.perform }
    end

    it "increments the counter" do
      expect(InstStatsd::Statsd).to receive(:count)
        .twice.with(array_including(/\.create$/), 1, 1, short_stat: anything, tags: {})
      Delayed::Job.all.each do |job|
        Delayed::Worker.lifecycle.run_callbacks(:create, job) {}
      end
    end
  end
end
