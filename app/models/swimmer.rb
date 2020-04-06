class Swimmer < ApplicationRecord
  has_many :swimmer_aliases, dependent: :delete_all
  has_and_belongs_to_many :meets

  validates :usms_permanent_id, presence: true, uniqueness: { case_sensitive: false }
  validates :gender, inclusion: { in: %w(M F), allow_nil: true }

  after_save :create_swimmer_alias

  def self.reconcile_meets
    all.each do |swimmer|
      Rails.logger.info("Reconciling meets for swimmer with permanent ID #{swimmer.usms_permanent_id}")
      begin
        swimmer.reconcile_meets
      rescue => e
        "ERROR: Failed to reconcile meets for swimmer with permanent ID #{swimmer.usms_permanent_id}\n#{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
  end

  def reconcile_meets
    usms_meet_ids = UsmsService.get_swimmer_meet_ids(usms_permanent_id)
    usms_meet_ids.each do |usms_meet_id|
      meet = Meet.find_by(usms_meet_id: usms_meet_id)
      if meet.nil?
        meet = UsmsService.fetch_meet(usms_meet_id)
        meets.reload
      end
      if meet && !meet_ids.include?(meet.id)
        meets.append(meet)
        save!
      end
    end
  end

  private

  def create_swimmer_alias
    swimmer_aliases.find_or_create_by(
      first_name: first_name,
      last_name: last_name
    )
  end
end
