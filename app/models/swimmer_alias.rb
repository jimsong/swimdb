class SwimmerAlias < ApplicationRecord
  belongs_to :swimmer, optional: true

  validates :first_name, uniqueness: { scope: :last_name }
end
