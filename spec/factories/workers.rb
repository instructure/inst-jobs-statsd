# frozen_string_literal: true

class WorkerFixture
  attr_accessor :name
end

FactoryBot.define do
  factory :worker_fixture, aliases: [:worker] do
    sequence(:name) { |n| "worker-#{n}" }
  end
end
