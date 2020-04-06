FactoryBot.define do
  factory :meet do
    sequence(:usms_meet_id) { |n| "mid#{n}" }
    sequence(:name) { |n| "Meet #{n}" }
    year { Date.today.year }
  end
end
