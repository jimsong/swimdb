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

  task monitor_open_slots: :environment do
    id = 6
    service = SignUpGeniusService.new(id)

    puts 'Initializing service'
    open_slots = Set.new(service.open_slots)
    new_open_slots = open_slots
    # open_slots = Set.new

    while true do
      puts 'Polling SignUpGenius'
      begin
        new_open_slots = Set.new(service.open_slots)
      rescue => e
        puts "Error polling SignUpGenius"
      end

      found_slots = new_open_slots - open_slots
      open_slots = new_open_slots
      if found_slots.count > 0
        puts 'Found new slots'
        puts found_slots.inspect
        message = <<~HEREDOC
          New time#{ found_slots.count > 1 ? 's' : '' } available!
          #{found_slots.map {|slot| puts slot.inspect; "#{slot[:date]} #{slot[:time]}"}.join("\n")}
          Go <#{service.url}|here> to sign up
        HEREDOC
        SlackService.send_message(SlackService::POOL_NOTIFICATIONS, message)
      else
        puts 'No new slots found'
      end

      sleep 60
    end
  end

end
