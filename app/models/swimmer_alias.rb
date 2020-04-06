class SwimmerAlias < ApplicationRecord
  belongs_to :swimmer, optional: true

  validates :first_name, uniqueness: { scope: :last_name, case_sensitive: false }

  def link_to_usms_permanent_id(usms_permanent_id)
    self.swimmer = UsmsService.fetch_swimmer(usms_permanent_id)
    save
  end
end
