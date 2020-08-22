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

  task :monitor_open_slots, [:urlid] => :environment do |_, args|
    service = SignUpGeniusService.new(args[:urlid])

    puts 'Initializing service'
    open_slots = Set.new(service.open_slots)
    new_open_slots = open_slots
    log_slots(new_open_slots)
    puts "Initialized, now polling once a minute"

    while true do
      begin
        new_open_slots = Set.new(service.open_slots)
      rescue => e
        puts "Error polling SignUpGenius at #{Time.now}: #{e}"
      end

      if open_slots != new_open_slots
        log_slots(new_open_slots)
      end

      found_slots = new_open_slots - open_slots
      open_slots = new_open_slots
      if found_slots.count > 0
        puts "Found new slots at #{Time.now}"
        send_message(service, found_slots)
      end

      sleep 60
    end
  end

  def log_slots(slots)
    filename = "log/slots-#{Time.now.strftime("%Y%m%d-%H%M%S")}.json"
    content = JSON.pretty_generate(slots.to_a)
    File.write(filename, content)
  end

  def send_message(service, open_slots)
    message = <<~HEREDOC
      New slot#{ open_slots.count > 1 ? 's' : '' } available!
      #{open_slots.map {|slot| "#{slot[:date]} #{slot[:time]} #{slot[:pool]}"}.join("\n")}
      Go <#{service.url}|here> to sign up
    HEREDOC
    SlackService.send_message(SlackService::POOL_NOTIFICATIONS, message)
  end

end
