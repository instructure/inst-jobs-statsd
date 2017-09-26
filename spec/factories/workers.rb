FactoryGirl.define do
  class WorkerFixture
    attr_accessor :name
  end

  factory :worker_fixture, aliases: [:worker] do
    sequence(:name) { |n| "worker-#{n}" }
  end
end
