FactoryBot.define do
  factory :swimmer do
    sequence(:usms_permanent_id) { |n| "id#{n}" }
    sequence(:first_name) { |n| "First#{n}" }
    middle_initial { ('A'..'Z').to_a.sample }
    sequence(:last_name) { |n| "Last#{n}" }
    gender { %w(M W).sample }
    birth_date { Date.today }
  end
end
