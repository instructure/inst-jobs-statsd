RSpec.describe InstJobsStatsd::Naming do
  describe '.qualified_names' do
    subject { InstJobsStatsd::Naming.qualified_names(stat_name, job) }
    let(:stat_name) { :wut }

    context 'when no job is given' do
      let(:job) { nil }
      it { should eq ['delayedjob.wut'] }
    end

    context 'when job is given' do
      let(:job) { build :job }
      it { should include 'delayedjob.wut.tag.Test-Job.perform' }

      context 'job tag is unusual' do
        let(:job) { build :job, tag: 'periodic__Something_on_a_schedule' }
        it { should include 'delayedjob.wut.tag.periodic__Something_on_a_schedule' }
      end

      context 'job tag is dynamic' do
        let(:job) { build :job, tag: '<Class:0x00000004f575b8>#perform' }
        it { should eq ['delayedjob.wut'] }
      end
    end
  end
end
