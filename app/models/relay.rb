class Relay < ApplicationRecord
  belongs_to :meet
  belongs_to :event
  belongs_to :age_group
  belongs_to :swimmer1, class_name: 'Swimmer', optional: true
  belongs_to :swimmer2, class_name: 'Swimmer', optional: true
  belongs_to :swimmer3, class_name: 'Swimmer', optional: true
  belongs_to :swimmer4, class_name: 'Swimmer', optional: true

  validates :time_ms, numericality: { only_integer: true, greater_than: 0 }
end
