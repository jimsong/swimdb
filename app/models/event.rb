class Event < ApplicationRecord
  has_many :meet_events
  has_many :meets, through: :meet_events
  has_many :results
  has_many :relays

  COURSES = %w(SCY SCM LCM).freeze
  STROKES = %w(Fly Back Breast Free IM).freeze

  # e.g. "50 Free"
  def self.find_by_course_and_name(course, event_name)
    parts = event_name.strip.split(/\s+/)
    distance = parts[0].to_i
    stroke =
        case parts[1].downcase
        when /^(butter)?fly/ then 'Fly'
        when /^back/ then 'Back'
        when /^breast/ then 'Breast'
        when /^free/ then 'Free'
        when /^i|m/ then 'IM'
        else nil
        end

    find_by!(course: course, distance: distance, stroke: stroke)
  end
end
