# frozen_string_literal: true

RSpec.describe InstJobsStatsd::JobsTracker do
  describe ".track" do
    it "calls the block" do
      @done_in_block = false
      expect do
        described_class.track do
          @done_in_block = true
        end
      end.to(change { @done_in_block })
    end
  end

  describe ".initialize" do
    it "enables everything" do
      expect(InstJobsStatsd::Stats::Counters::Create).to receive(:enable)
      expect(InstJobsStatsd::Stats::Counters::Run).to receive(:enable)
      expect(InstJobsStatsd::Stats::Counters::Complete).to receive(:enable)

      expect(InstJobsStatsd::Stats::Periodic::Failed).to receive(:enable)
      expect(InstJobsStatsd::Stats::Periodic::Queue).to receive(:enable)
      expect(InstJobsStatsd::Stats::Periodic::Run).to receive(:enable)

      expect(InstJobsStatsd::Stats::Timing::Failed).to receive(:enable)
      expect(InstJobsStatsd::Stats::Timing::Perform).to receive(:enable)
      expect(InstJobsStatsd::Stats::Timing::Pop).to receive(:enable)

      described_class.new
    end
  end
end
