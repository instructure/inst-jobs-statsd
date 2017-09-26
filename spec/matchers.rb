RSpec::Matchers.define :number_near do |target, max_delta = 0.5|
  match { |actual| (actual - target).abs <= max_delta }
end
