namespace :swimdb do

  task ad_hoc: :environment do
    meet = Meet.find(1002)
    SwimPhoneService.fetch_meet_dates(meet)
  end

end
