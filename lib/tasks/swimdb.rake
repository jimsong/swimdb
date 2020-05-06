namespace :swimdb do

  task ad_hoc: :environment do
    Meet.where("club_assistant_meet_id IS NOT NULL AND start_date != end_date").each do |m|
      SwimPhoneService.fetch_relay_dates(m)
    end
  end

end
