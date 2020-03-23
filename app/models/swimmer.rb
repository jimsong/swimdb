class Swimmer < ApplicationRecord
  validates :permanent_id, presence: true
  validates :gender, inclusion: { in: %w(M F) }
  validates :birth_date, presence: true
end
