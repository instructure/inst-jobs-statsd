FactoryGirl.define do
  class JobFixture
    attr_accessor :tag, :run_at, :strand
  end

  factory :job_fixture, aliases: [:job] do
    tag 'Test::Job.perform'
  end
end
