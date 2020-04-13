class Meet < ApplicationRecord
  has_many :results
  has_many :swimmers, -> { distinct },through: :results

  validates :usms_meet_id, presence: true, uniqueness: { case_sensitive: false }

  def self.prune
    all.each do |meet|
      if meet.swimmers.count == 0
        meet.destroy
      end
    end
  end
end
