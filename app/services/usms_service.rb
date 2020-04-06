module UsmsService
  BASE_URL = 'https://usms.org'

  def self.get_swimmer_info(usms_permanent_id)
    url = File.join(BASE_URL, '/people', usms_permanent_id)
    response = RestClient.get(url)
    page = Nokogiri::HTML(response)
    name = page.css('div.contenttext div table tr')[1].css("td")[1].text
    name_parts = name.strip.split(/\s+/)
    Swimmer.new(
      usms_permanent_id: usms_permanent_id,
      first_name: name_parts[0],
      last_name: name_parts[-1]
    )
  end

  def self.fetch_swimmers_by_name(first_name, last_name, year)
    swimmer = Swimmer.find_by(first_name: first_name, last_name: last_name)
    if swimmer
      Rails.logger.info("Found existing swimmer #{first_name} #{last_name} with permanent ID #{swimmer.usms_permanent_id}")
      return swimmer
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
    json_body['rows'].map do |row|
      next if row['ClubAbbr'] != 'MEMO'
      usms_permanent_id = row['RegNumber'].split('-')[1]
      Rails.logger.info("Found new swimmer #{first_name} #{last_name} with permanent ID #{usms_permanent_id}")
      swimmer = Swimmer.find_or_initialize_by(
        usms_permanent_id: usms_permanent_id
      )
      swimmer.update(
        first_name: row['FirstName'],
        middle_initial: row['MI'],
        last_name: row['LastName']
      )
      swimmer
    end.compact
  end

  def self.get_meet_swimmer_names(usms_meet_id)
    url = File.join(BASE_URL, '/comp/meets/meetsearch.php')
    params = { club: 'MEMO', MeetID: usms_meet_id }
    response = RestClient.get(url, params: params)

    page = Nokogiri::HTML(response)
    text = page.css('div.contenttext pre')[0].text
    matches = text.scan(/\n.{5}([a-zA-Z, ]*)\d+  MEMO/)

    matches.map do |match|
      match[0].strip
    end.uniq.map do |last_name_first|
      names = last_name_first.split(/[, ]+/)
      {
        first_name: names[1],
        last_name: names[0]
      }
    end
  end

  def self.fetch_swimmers_from_meet(usms_meet_id)
    swimmers = []

    Rails.logger.info("Fetching swimmers from meet #{usms_meet_id}")
    year = usms_meet_id[0, 4].to_i
    swimmer_names = get_meet_swimmer_names(usms_meet_id)

    swimmer_names.each do |swimmer_name|
      first_name = swimmer_name[:first_name]
      last_name = swimmer_name[:last_name]
      Rails.logger.info("Fetching swimmer #{first_name} #{last_name}")
      begin
        swimmers.concat fetch_swimmers_by_name(first_name, last_name, year)
      rescue => e
        Rails.logger.error("ERROR: Failed to fetch swimmer #{first_name} #{last_name}\n#{e.message}\n#{e.backtrace.join("\n")}")
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

end
