FactoryBot.define do
  factory :swimmer do
    sequence(:usms_permanent_id) { |n| "id#{n}" }
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    gender { %w(M F).sample }
    birth_date { Date.today }
  end
end
