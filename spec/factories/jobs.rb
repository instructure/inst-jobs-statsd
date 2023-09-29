# frozen_string_literal: true

class JobFixture
  attr_accessor :tag, :run_at, :priority
end

FactoryBot.define do
  factory :job_fixture, aliases: [:job] do
    tag { "Test::Job.perform" }
  end
end
