RSpec.describe InstJobsStatsd::Stats::Periodic do
  before(:each) do
    Delayed::Worker.lifecycle.reset!
    InstJobsStatsd::Stats::Periodic.instance_variable_set(:@instance, nil)
  end

  describe '.enable_callbacks' do
    it 'only happens once' do
      expect(InstJobsStatsd::Stats::Periodic::Callbacks).to receive(:new).once.and_call_original
      2.times { InstJobsStatsd::Stats::Periodic.enable_callbacks }
    end
  end

  describe '.add' do
    it 'does nothing if not enabled' do
      expect_any_instance_of(InstJobsStatsd::Stats::Periodic::Callbacks).not_to receive(:add)
      InstJobsStatsd::Stats::Periodic.add(-> {})
    end

    it 'does something if enabled' do
      expect_any_instance_of(InstJobsStatsd::Stats::Periodic::Callbacks)
        .to receive(:add).and_call_original
      InstJobsStatsd::Stats::Periodic.enable_callbacks
      InstJobsStatsd::Stats::Periodic.add(-> {})
    end
  end

  describe 'Callbacks' do
    before(:each) do
      InstJobsStatsd::Stats::Periodic.instance_variable_set(:@instance, nil)
    end

    it 'calls the procs at the interval' do
      InstJobsStatsd::Stats::Periodic.enable_callbacks

      @count = 0
      InstJobsStatsd::Stats::Periodic.add(-> { @count += 1 })
      InstJobsStatsd::Stats::Periodic.add(-> { @count += 2 })

      Timecop.freeze(Delayed::Job.db_time_now + 60.seconds) do
        Delayed::Worker.lifecycle.run_callbacks(:work_queue_pop, nil, nil) {}
      end

      expect(@count).to eq 3
    end
  end

  describe 'Timer' do
    before(:each) { @did_block = false }

    it 'does not call the block too soon' do
      t = InstJobsStatsd::Stats::Periodic::Timer.new(60)
      expect { t.tick { @did_block = true } }.not_to(change { @did_block })
    end

    it 'calls the block after the interval elapses' do
      t = InstJobsStatsd::Stats::Periodic::Timer.new(60)
      Timecop.freeze(Delayed::Job.db_time_now + 60.seconds) do
        expect { t.tick { @did_block = true } }.to(change { @did_block })
      end
    end
  end
end
