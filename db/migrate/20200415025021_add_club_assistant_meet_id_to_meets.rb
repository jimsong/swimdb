class AddClubAssistantMeetIdToMeets < ActiveRecord::Migration[6.0]
  def change
    add_column :meets, :club_assistant_meet_id, :string, after: :usms_meet_id
  end
end
