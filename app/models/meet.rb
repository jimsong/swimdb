class Meet < ApplicationRecord
  validates :usms_meet_id, presence: true, uniqueness: true
end
