class Swimmer < ApplicationRecord
  has_many :swimmer_aliases, dependent: :delete_all

  validates :usms_permanent_id, presence: true, uniqueness: true
  validates :gender, inclusion: { in: %w(M F), allow_nil: true }

  after_save :create_swimmer_alias

  def reconcile_meets
    usms_meet_ids = UsmsService.get_swimmer_meet_ids(usms_permanent_id)
    usms_meet_ids.each do |usms_meet_id|
      if Meet.where(usms_meet_id: usms_meet_id).none?
        UsmsService.fetch_meet(usms_meet_id)
      end
    end
  end

  def create_swimmer_alias
    swimmer_aliases.find_or_create_by(
      first_name: first_name,
      last_name: last_name
    )
  end
end
