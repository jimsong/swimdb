class Meet < ApplicationRecord
  has_and_belongs_to_many :swimmers

  validates :usms_meet_id, presence: true, uniqueness: { case_sensitive: false }

  def self.prune
    all.each do |meet|
      if meet.swimmers.count == 0
        meet.destroy
      end
    end
  end
end
