# frozen_string_literal: true

RSpec.describe InstJobsStatsd::Naming do
  describe ".qualified_names" do
    subject { described_class.qualified_names(stat_name, job) }

    let(:stat_name) { :wut }

    context "when no job is given" do
      let(:job) { nil }

      it { is_expected.to eq ["delayedjob.wut"] }
    end

    context "when job is given" do
      let(:job) { build(:job) }

      it { is_expected.to include "delayedjob.wut.tag.Test-Job.perform" }

      context "with unusual job tag" do
        let(:job) { build(:job, tag: "periodic__Something_on_a_schedule") }

        it { is_expected.to include "delayedjob.wut.tag.periodic__Something_on_a_schedule" }
      end

      context "with dynamic job tag" do
        let(:job) { build(:job, tag: "<Class:0x00000004f575b8>#perform") }

        it { is_expected.to eq ["delayedjob.wut"] }
      end
    end

    context "with region tags" do
      before do
        @jobs_namespace = ENV["INST_JOBS_STATSD_NAMESPACE"]
        ENV["INST_JOBS_STATSD_NAMESPACE"] = "region_name"
      end

      after do
        ENV["INST_JOBS_STATSD_NAMESPACE"] = @jobs_namespace
      end

      let(:job) { build(:job, tag: "a_tag_name") }

      it { is_expected.to include "delayedjob.wut" }
      it { is_expected.to include "delayedjob.wut.tag.a_tag_name" }
      it { is_expected.to include "delayedjob.wut.region_name" }
      it { is_expected.to include "delayedjob.wut.region_name.tag.a_tag_name" }
    end

    describe ".dd_job_tags" do
      it "returns the tag hash for the given job" do
        job = double(tag: "Account.run_reports_later", priority: nil)
        expect(described_class.dd_job_tags(job)).to eq(tag: "Account.run_reports_later")
      end

      it "properly munges job tags" do
        job = double(tag: "Quizzes::Quiz#do_something", priority: nil)
        expect(described_class.dd_job_tags(job)).to eq(tag: "Quizzes-Quiz.do_something")
      end

      context "when job has a priority" do
        it "includes the priority tag" do
          job = double(tag: "Account.run_reports_later", priority: Delayed::NORMAL_PRIORITY)
          expect(described_class.dd_job_tags(job)).to eq(tag: "Account.run_reports_later",
                                                         priority: Delayed::NORMAL_PRIORITY)
        end
      end

      it "includes the cluster tag if the job has a shard" do
        job = double(tag: "Account.run_reports_later",
                     priority: nil,
                     current_shard: double(database_server: double(id: "cluster6")))
        expect(described_class.dd_job_tags(job)).to eq(tag: "Account.run_reports_later", cluster: "cluster6")
      end
    end
  end
end
