namespace :swimdb do

  task ad_hoc: :environment do
    Meet.all.each do |m|
      begin
        UsmsService.fetch_meet_relays(m)
      rescue => e
        Rails.logger.error("ERROR: Failed to fetch relays for meet #{m.usms_meet_id}")
      end
    end; nil
  end

end
