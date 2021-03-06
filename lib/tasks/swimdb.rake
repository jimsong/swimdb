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

  task :monitor_open_slots, [:urlid, :channel_id] => :environment do |_, args|
    service = SignUpGeniusService.new(args[:urlid])
    channel_id = args[:channel_id]

    puts 'Initializing service'
    open_slots = Set.new(service.open_slots)
    new_open_slots = open_slots
    log_slots(new_open_slots)
    puts "Initialized, now polling once a minute"

    while true do
      begin
        new_open_slots = Set.new(service.open_slots)
      rescue => e
        time = Time.now
        puts "Error polling SignUpGenius at #{time}: #{e}"
        # filename = "log/response-#{time.strftime("%Y%m%d-%H%M%S")}.html"
        # File.write(filename, service.response.body)
      end

      if open_slots != new_open_slots
        log_slots(new_open_slots)
      end

      found_slots = new_open_slots - open_slots
      open_slots = new_open_slots
      if found_slots.count > 0
        puts "Found new slots at #{Time.now}"
        send_message(service, channel_id, found_slots)
      end

      sleep 60
    end
  end

  def log_slots(slots)
    # filename = "log/slots-#{Time.now.strftime("%Y%m%d-%H%M%S")}.json"
    # content = JSON.pretty_generate(slots.to_a)
    # File.write(filename, content)
  end

  def send_message(service, channel_id, open_slots)
    message = <<~HEREDOC
      <!channel> New slot#{ open_slots.count > 1 ? 's' : '' } available!
      #{open_slots.map {|slot| "#{slot[:date]} #{slot[:time]} #{slot[:pool]}"}.join("\n")}
      Go <#{service.url}|here> to sign up
    HEREDOC
    Thread.new do
      SlackService.send_message(SlackService::JIMMY_USER, message)
      sleep 60
      SlackService.send_message(channel_id, message)
    end
  end

end
