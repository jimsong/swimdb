class Swimmer < ApplicationRecord
  validates :usms_permanent_id, presence: true, uniqueness: true
  validates :gender, inclusion: { in: %w(M F) }
  validates :birth_date, presence: true
end
