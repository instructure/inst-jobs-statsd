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

    context 'with region tags' do
      before do
        @jobs_namespace = ENV['INST_JOBS_STATSD_NAMESPACE']
        ENV['INST_JOBS_STATSD_NAMESPACE'] = 'region_name'
      end

      after do
        ENV['INST_JOBS_STATSD_NAMESPACE'] = @jobs_namespace
      end

      let(:job) { build :job, tag: 'a_tag_name' }

      it { should include 'delayedjob.wut' }
      it { should include 'delayedjob.wut.tag.a_tag_name' }
      it { should include 'delayedjob.wut.region_name' }
      it { should include 'delayedjob.wut.region_name.tag.a_tag_name' }
    end
  end
end
