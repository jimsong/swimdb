FactoryBot.define do
  factory :meet do
    sequence(:usms_meet_id) { |n| "mid#{n}" }
  end
end
