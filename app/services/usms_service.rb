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
    year = usms_meet_id[0, 4].to_i
    Rails.logger.info("Found new meet \"#{name}\" with ID #{usms_meet_id}")

    meet = Meet.find_or_initialize_by(
        usms_meet_id: usms_meet_id,
    )
    meet.update(name: name, year: year)

    meet
  end

  def self.fetch_swimmers_by_name(first_name, last_name, year)
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
        last_name: row['LastName']&.strip
      )
      swimmer
    end.compact

    if swimmers.empty?
      raise StandardError.new('No matching swimmers found')
    end
    swimmers
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
      elsif line =~ /^.{5}([a-zA-Z, ]*)\d+  MEMO/
        full_name = $1.strip
        unless infos.has_key?(full_name)
          name_parts = full_name.split(',')
          infos[full_name] = {
            first_name: name_parts[1].split(' ')[0],
            last_name: name_parts[0],
            gender: current_gender
          }
        end
      end
    end

    infos.values
  end

  def self.fetch_swimmers_from_meet(usms_meet_id)
    swimmers = []
    meet = Meet.find_by(usms_meet_id: usms_meet_id)

    Rails.logger.info("=== Fetching swimmers from meet #{usms_meet_id} ===")
    year = usms_meet_id[0, 4].to_i
    swimmer_names = get_meet_swimmer_infos(usms_meet_id)

    swimmer_names.each do |swimmer_info|
      first_name = swimmer_info[:first_name]
      last_name = swimmer_info[:last_name]
      Rails.logger.info("Fetching swimmer #{first_name} #{last_name}")
      begin
        found_swimmers = fetch_swimmers_by_name(first_name, last_name, year)
        found_swimmers.each do |swimmer|
          swimmer.update!(gender: swimmer_info[:gender])
        end
        swimmers.concat(found_swimmers)
      rescue => e
        Rails.logger.error("ERROR: Failed to fetch swimmer #{first_name} #{last_name}\n#{e.message}\n#{e.backtrace.join("\n")}")
        SwimmerAlias.find_or_create_by(first_name: first_name, last_name: last_name)
      end
    end

    swimmers.each do |swimmer|
      if meet && !swimmer.meet_ids.include?(meet.id)
        swimmer.meets.append(meet)
        swimmer.save!
      end
    end

    swimmers
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
        swimmers.concat fetch_swimmers_from_meet(meet.usms_meet_id)
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

end
