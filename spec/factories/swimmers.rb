FactoryBot.define do
  factory :swimmer do
    sequence(:usms_permanent_id) { |n| "pid#{n}" }
    first_name { "First" }
    last_name  { "Last" }
    gender { %w(M F).sample }
    birth_date { Date.today }
  end
end
