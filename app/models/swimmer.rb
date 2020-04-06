class Swimmer < ApplicationRecord
  validates :usms_permanent_id, presence: true, uniqueness: true
  validates :gender, inclusion: { in: %w(M F), allow_nil: true }

  def reconcile_meets
    usms_meet_ids = UsmsService.get_swimmer_meet_ids(usms_permanent_id)
    usms_meet_ids.each do |usms_meet_id|
      UsmsService.fetch_meet(usms_meet_id)
    end
  end
end
