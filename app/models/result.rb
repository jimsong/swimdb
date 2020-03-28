class Result < ApplicationRecord
  belongs_to :meet
  belongs_to :event
  belongs_to :age_group
  belongs_to :swimmer

  validates :time_ms, numericality: { only_integer: true, greater_than: 0 }
end
