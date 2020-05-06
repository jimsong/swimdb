class Meet < ApplicationRecord
  has_many :meet_events
  has_many :events, through: :meet_events
  has_many :results
  has_many :relays
  has_many :swimmers, -> { distinct }, through: :results

  validates :usms_meet_id, presence: true, uniqueness: { case_sensitive: false }

  def url
    "https://usms.org/comp/meets/meet.php?MeetID=#{usms_meet_id}"
  end

  def self.prune
    all.each do |meet|
      if meet.swimmers.count == 0
        meet.destroy
      end
    end
  end
end
