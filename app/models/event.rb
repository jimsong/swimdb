class Event < ApplicationRecord
  has_many :results

  COURSES = %w(SCY SCM LCM).freeze
  STROKES = %w(butterfly backstroke breaststroke freestyle medley).freeze

  # e.g. "50 Free"
  def self.find_by_course_and_name(course, event_name)
    parts = event_name.strip.split(/\s+/)
    distance = parts[0].to_i
    stroke =
        case parts[1].downcase
        when /^(butter)?fly/ then 'butterfly'
        when /^back/ then 'backstroke'
        when /^breast/ then 'breaststroke'
        when /^free/ then 'freestyle'
        when /^i|m/ then 'medley'
        else nil
        end

    find_by!(course: course, distance: distance, stroke: stroke)
  end
end
