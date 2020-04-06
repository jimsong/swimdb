FactoryBot.define do
  factory :swimmer_alias do
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    swimmer
  end
end
