# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Stats::Periodic do
  before do
    Delayed::Worker.lifecycle.reset!
    described_class.instance_variable_set(:@instance, nil)
  end

  describe ".enable_callbacks" do
    it "only happens once" do
      expect(InstJobsStatsd::Stats::Periodic::Callbacks).to receive(:new).once.and_call_original
      2.times { described_class.enable_callbacks }
    end
  end

  describe ".add" do
    it "does nothing if not enabled" do
      expect_any_instance_of(InstJobsStatsd::Stats::Periodic::Callbacks).not_to receive(:add)
      described_class.add(-> {})
    end

    it "does something if enabled" do
      expect_any_instance_of(InstJobsStatsd::Stats::Periodic::Callbacks)
        .to receive(:add).and_call_original
      described_class.enable_callbacks
      described_class.add(-> {})
    end
  end

  describe "Callbacks" do
    before do
      described_class.instance_variable_set(:@instance, nil)
    end

    it "calls the procs at the interval" do
      described_class.enable_callbacks

      @count = 0
      described_class.add(-> { @count += 1 })
      described_class.add(-> { @count += 2 })

      Timecop.freeze(Delayed::Job.db_time_now + 60.seconds) do
        Delayed::Worker.lifecycle.run_callbacks(:work_queue_pop, nil, nil) { nil }
      end

      expect(@count).to eq 3
    end
  end

  describe "Timer" do
    before { @did_block = false }

    it "does not call the block too soon" do
      t = InstJobsStatsd::Stats::Periodic::Timer.new(60)
      expect { t.tick { @did_block = true } }.not_to(change { @did_block })
    end

    it "calls the block after the interval elapses" do
      t = InstJobsStatsd::Stats::Periodic::Timer.new(60)
      Timecop.freeze(Delayed::Job.db_time_now + 60.seconds) do
        expect { t.tick { @did_block = true } }.to(change { @did_block })
      end
    end
  end
end
