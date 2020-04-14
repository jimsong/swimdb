FactoryBot.define do
  factory :meet_event do
    meet
    event do
      Event.find_or_create_by(
        distance: [100, 200].sample,
        course: Event::COURSES.sample,
        stroke: Event::STROKES.sample,
      )
    end
    event_number { 1 }
    event_date { Date.today }
  end
end
