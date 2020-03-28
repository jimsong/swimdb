FactoryBot.define do
  factory :result do
    meet
    event do
      Event.find_or_create_by(
        distance: [100, 200].sample,
        course: Event::COURSES.sample,
        stroke: Event::STROKES.sample,
      )
    end
    age_group do
      start_age = [25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100].sample
      AgeGroup.find_or_create_by(
        gender: AgeGroup::GENDERS.sample,
        start_age: start_age,
        end_age: start_age + 4,
      )
    end
    swimmer
    time_ms { rand(60_000..120_000) }
  end
end
