module UsmsService
  BASE_URL = 'https://usms.org'
  NBSP = 160.chr(Encoding::UTF_8)

  def self.fetch_swimmer(usms_permanent_id)
    Rails.logger.info("Fetching swimmer with permanent ID #{usms_permanent_id}")
    url = File.join(BASE_URL, '/people', usms_permanent_id)
    response = RestClient.get(url)

    page = Nokogiri::HTML(response)
    name = page.css('div.contenttext div table tr')[1].css("td")[1].text
    name_parts = name.strip.split(/\s+/)
    middle_initial = name_parts[1..-2].find { |part| part.length == 1 }
    name_parts.reject! { |part| part.length < 2 }
    first_name = name_parts[0]
    last_name = name_parts[1..-1].join(' ')
    Rails.logger.info("Found new swimmer #{first_name} #{last_name} with permanent ID #{usms_permanent_id}")

    swimmer = Swimmer.find_or_initialize_by(
      usms_permanent_id: usms_permanent_id
    )
    swimmer.update(
      first_name: first_name,
      middle_initial: middle_initial,
      last_name: last_name
    )

    swimmer
  end

  def self.fetch_meet(usms_meet_id)
    Rails.logger.info("Fetching meet with ID #{usms_meet_id}")
    url = File.join(BASE_URL, '/comp/meets/meet.php')
    params = { MeetID: usms_meet_id }
    response = RestClient.get(url, params: params)
    page = Nokogiri::HTML(response)

    name = page.css('div.contenttext h3')[0].text

    links = page.css('div.contenttext table a')
    club_assistant_meet_id = links.detect do |link|
      if link['href'] =~ /smid=(\d+)/
        break $1
      end
    end

    trs = page.css('div.contenttext table tr')
    course = trs[0].css('td').text.strip
    date_text = trs[1].css('td').text.strip
    if date_text =~ /\A(\w+) (\d+), (\d+)\z/
      start_month = end_month = $1
      start_day = end_day = $2
      year = $3
    elsif date_text =~ /\A(\w+) (\d+)-(\d+), (\d+)\z/
      start_month = end_month = $1
      start_day = $2
      end_day = $3
      year = $4
    elsif date_text =~ /\A(\w+) (\d+) - (\w+) (\d+), (\d+)\z/
      start_month = $1
      start_day = $2
      end_month = $3
      end_day = $4
      year = $5
    else
      Rails.logger.error("ERROR: Failed to fetch meet dates for meet with ID #{usms_meet_id}")
      return
    end

    start_date = Date.parse("#{start_month} #{start_day}, #{year}")
    end_date = Date.parse("#{end_month} #{end_day}, #{year}")

    Rails.logger.info("Found meet \"#{name}\" with ID #{usms_meet_id}")

    meet = Meet.find_or_initialize_by(
        usms_meet_id: usms_meet_id,
    )
    meet.update(
      name: name,
      year: start_date.year,
      start_date: start_date,
      end_date: end_date,
      club_assistant_meet_id: meet.club_assistant_meet_id || club_assistant_meet_id,
      course: course
    )

    meet
  end

  def self.fetch_swimmers_by_name(first_name, last_name, year, gender = nil)
    swimmer = Swimmer.find_by(first_name: first_name, last_name: last_name)
    if swimmer.nil?
      swimmer_alias = SwimmerAlias.find_by(first_name: first_name, last_name: last_name)
      if swimmer_alias
        swimmer = swimmer_alias.swimmer
      end
    end
    if swimmer
      Rails.logger.info("Found existing swimmer #{first_name} #{last_name} with permanent ID #{swimmer.usms_permanent_id}")
      return [swimmer]
    end

    url = File.join(BASE_URL, '/reg/members/jqs/searchmembers.php')
    params = {
      RegYear: year,
      FirstName: first_name,
      LastName: last_name,
      oper: 'grid',
    }
    response = RestClient.get(url, params: params)

    json_body = JSON.parse(response.body)
    swimmers = json_body['rows'].map do |row|
      next if row['ClubAbbr'] != 'MEMO'
      usms_permanent_id = row['RegNumber'].split('-')[1]
      Rails.logger.info("Found new swimmer #{first_name} #{last_name} with permanent ID #{usms_permanent_id}")
      swimmer = Swimmer.find_or_initialize_by(
        usms_permanent_id: usms_permanent_id
      )
      swimmer.update(
        first_name: row['FirstName']&.strip,
        middle_initial: row['MI']&.strip,
        last_name: row['LastName']&.strip,
        gender: gender
      )
      swimmer.swimmer_aliases.find_or_create_by(first_name: first_name, last_name: last_name)
      swimmer
    end.compact

    if swimmers.empty?
      raise StandardError.new('No matching swimmers found')
    end
    swimmers
  end

  def self.parse_last_name_comma_first(text)
    full_name = text.strip
    name_parts = full_name.split(',')
    {
      first_name: name_parts[1].split(' ')[0],
      last_name: name_parts[0].strip,
    }
  end

  def self.get_meet_swimmer_infos(usms_meet_id)
    url = File.join(BASE_URL, '/comp/meets/meetsearch.php')
    params = { club: 'MEMO', MeetID: usms_meet_id }
    response = RestClient.get(url, params: params)

    page = Nokogiri::HTML(response)
    text = page.css('div.contenttext pre')[0].text

    current_gender = nil
    infos = {}

    text.lines.each do |line|
      if line.start_with?('Women')
        current_gender = 'W'
      elsif line.start_with?('Men')
        current_gender = 'M'
      elsif line =~ /^.{5}(.*)\d+  MEMO/
        full_name = $1.strip
        unless infos.has_key?(full_name)
          infos[full_name] = parse_last_name_comma_first(full_name).merge(gender: current_gender)
        end
      end
    end

    text = page.css('div.contenttext pre')[1].text
    text.scan(/\d\) (\D+) [MF]\d{2,}/).each do |match|
      full_name = match[0]
      unless infos.has_key?(full_name)
        infos[full_name] = parse_last_name_comma_first(full_name)
      end
    end

    infos.values
  end

  def self.fetch_swimmers_from_meet(meet)
    usms_meet_id = meet.usms_meet_id
    swimmers = []
    meet = Meet.find_by(usms_meet_id: usms_meet_id)

    Rails.logger.info("=== Fetching swimmers from meet #{usms_meet_id} ===")
    year = usms_meet_id[0, 4].to_i
    swimmer_names = get_meet_swimmer_infos(usms_meet_id)

    swimmer_names.each do |swimmer_info|
      first_name = swimmer_info[:first_name]
      last_name = swimmer_info[:last_name]
      gender = swimmer_info[:gender]
      Rails.logger.info("Fetching swimmer #{first_name} #{last_name}")
      begin
        found_swimmers = fetch_swimmers_by_name(first_name, last_name, year, gender)
        swimmers.concat(found_swimmers)
      rescue
        Rails.logger.error("ERROR: Failed to fetch swimmer #{first_name} #{last_name}")
        SwimmerAlias.find_or_create_by(first_name: first_name, last_name: last_name)
      end
    end

    swimmers
  end

  def self.fetch_relay_swimmer(first_name, last_name, year)
    begin
      fetch_swimmers_by_name(first_name, last_name, year)[0]
    rescue
      Rails.logger.error("ERROR: Failed to fetch swimmer #{first_name} #{last_name}")
      nil
    end
  end

  def self.fetch_meet_relays(meet)
    relays = []

    Rails.logger.info("=== Fetching relays for meet #{meet.usms_meet_id} ===")

    url = File.join(BASE_URL, '/comp/meets/meetsearch.php')
    params = { club: 'MEMO', MeetID: meet.usms_meet_id }
    response = RestClient.get(url, params: params)

    page = Nokogiri::HTML(response)
    text = page.css('div.contenttext pre')[1].text

    age_group = nil
    event = nil
    name = nil
    time_ms = nil
    swimmer1 = nil
    swimmer2 = nil
    swimmer3 = nil

    text.lines.each do |line|
      if line =~ /^(Women|Men|Mixed) (\d+)\S+ (\d+) \S+ (Medley|Free)/
        gender =
            case $1
            when 'Women' then 'W'
            when 'Men' then 'M'
            when 'Mixed' then 'X'
            else nil
            end
        start_age = $2
        age_group = AgeGroup.find_by(gender: gender, start_age: start_age.to_i, relay: true)
        distance = $3
        stroke = $4
        event = Event.find_by(distance: distance, course: meet.course, stroke: stroke, relay: true)
      elsif line =~ /^.{5}(MEMO \S+) +\S+ +(\S+)/
        name = $1
        time_ms = time_to_ms($2)
      else
        if line =~ /1\) (\D+) [MF]\d{2,}/
          parts = parse_last_name_comma_first($1)
          swimmer1 = fetch_relay_swimmer(parts[:first_name], parts[:last_name], meet.year)
        end
        if line =~ /2\) (\D+) [MF]\d{2,}/
          parts = parse_last_name_comma_first($1)
          swimmer2 = fetch_relay_swimmer(parts[:first_name], parts[:last_name], meet.year)
        end
        if line =~ /3\) (\D+) [MF]\d{2,}/
          parts = parse_last_name_comma_first($1)
          swimmer3 = fetch_relay_swimmer(parts[:first_name], parts[:last_name], meet.year)
        end
        if line =~ /4\) (\D+) [MF]\d{2,}/
          parts = parse_last_name_comma_first($1)
          swimmer4 = fetch_relay_swimmer(parts[:first_name], parts[:last_name], meet.year)
          relay = Relay.find_or_initialize_by(
            meet: meet,
            event: event,
            age_group: age_group,
            name: name
          )
          begin
            relay.update!(
              time_ms: time_ms,
              swimmer1: swimmer1,
              swimmer2: swimmer2,
              swimmer3: swimmer3,
              swimmer4: swimmer4
            )
            relays << relay
          rescue => e
            Rails.logger.error("ERROR: Failed to update relay for meet #{meet.usms_meet_id} event #{event.id}: #{e}")
          end
        end
      end
    end

    relays
  end

  def self.fetch_meets_from_year(year)
    Rails.logger.info("Fetching meets from #{year}")
    url = File.join(BASE_URL, '/comp/resultsnet.php')
    response = RestClient.get(url, params: { Year: year })

    page = Nokogiri::HTML(response)
    links = page.css('div.contenttext ul li a')

    links.map do |link|
      link['href'] =~ /MeetID=(.*)/
      usms_meet_id = $1
      name = link.text
      Rails.logger.info("Found meet \"#{name}\" with ID #{usms_meet_id}")
      meet = Meet.find_or_initialize_by(usms_meet_id: usms_meet_id)
      meet.update(name: name, year: year)
      meet
    end
  end

  def self.fetch_swimmers_from_year(year)
    swimmers = []

    Meet.where(year: year).each do |meet|
      begin
        swimmers.concat fetch_swimmers_from_meet(meet)
      rescue => e
        Rails.logger.error("ERROR: Failed to fetch swimmers from meet #{meet.usms_meet_id}\n#{e.message}\n#{e.backtrace.join("\n")}")
      end
    end

    swimmers
  end

  def self.get_swimmer_meet_ids(usms_permanent_id)
    usms_meet_ids = Set.new

    url = File.join(BASE_URL, '/comp/meets/indresults.php')
    params = { SwimmerID: usms_permanent_id }
    response = RestClient.get(url, params: params)

    page = Nokogiri::HTML(response)
    rows = page.css('table.indresults tr')

    rows.each do |row|
      tds = row.css('td')
      if tds.count == 8
        club = tds[3].text.gsub(NBSP, ' ').strip
        if club == 'MEMO'
          usms_meet_id = tds[1].css('a').text
          usms_meet_ids.add(usms_meet_id)
        end
      end
    end

    return usms_meet_ids.to_a
  end

  def self.fetch_swimmer_results(usms_permanent_id)
    Rails.logger.info("Fetching results for swimmer with permanent ID #{usms_permanent_id}")
    swimmer = Swimmer.find_by!(usms_permanent_id: usms_permanent_id)
    results = []

    url = File.join(BASE_URL, '/comp/meets/indresults.php')
    params = { SwimmerID: usms_permanent_id }
    response = RestClient.get(url, params: params)

    page = Nokogiri::HTML(response)
    tables = page.css('table.indresults')
    course = nil
    start_age = nil

    tables.each do |table|
      rows = table.css('tr')
      rows.each do |row|
        ths = row.css('th')
        if ths.count == 1 && ths[0]['colspan'] == '8'
          ths[0].text.gsub(NBSP, ' ').strip =~ /(.{3}) Results for (.*)-.* Age Group/
          course = $1
          start_age = $2.to_i
        end

        tds = row.css('td')
        if tds.count == 8
          club = tds[3].text.gsub(NBSP, ' ').strip
          if club == 'MEMO'
            date = Date.parse(tds[1].text.gsub(NBSP, ' ').strip[0, 10])
            usms_meet_id = tds[1].css('a').text
            meet = Meet.find_by!(usms_meet_id: usms_meet_id)
            event_name = tds[4].text.gsub(NBSP, ' ').strip
            event = Event.find_by_course_and_name(course, event_name)
            time_text = tds[6].text.gsub(NBSP, ' ').strip
            time_text =~ /((\d*):)?(\d+)\.(\d+)/
            time_ms = time_to_ms(time_text)
            age_group = AgeGroup.find_by!(gender: swimmer.gender, start_age: start_age)
            result = swimmer.results.find_or_initialize_by(meet: meet, event: event, age_group: age_group)
            begin
              result.update!(
                time_ms: [time_ms, result.time_ms].compact.min,
                date: result.date || date
              )
              results << result
            rescue => e
              Rails.logger.error("ERROR: Failed to fetch result for meet #{usms_meet_id} event #{event.id}: #{e}")
            end
          end
        end
      end
    end
    results.count
  end

  def self.time_to_ms(time_text)
    time_text =~ /((\d*):)?(\d+)\.(\d+)/
    minutes = $2.to_i
    seconds = $3.to_i
    centis = $4.to_i
    minutes * 60000 + seconds * 1000 + centis * 10
  end

  def self.ms_to_time(time_ms)
    minutes = time_ms / 60000
    remain = time_ms % 60000
    seconds = remain / 1000
    remain = remain % 1000
    centis = remain / 10

    minutes_text = minutes > 0 ? "#{minutes}:" : ""
    seconds_text = seconds < 10 ? seconds.to_s.rjust(2, '0') : seconds.to_s
    centis_text = centis < 10 ? centis.to_s.rjust(2, '0') : centis.to_s

    "#{minutes_text}#{seconds_text}.#{centis_text}"
  end
end
