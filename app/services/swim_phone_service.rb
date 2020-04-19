module SwimPhoneService
  BASE_URL = 'https://swimphone.com'
  NBSP = 160.chr(Encoding::UTF_8)

  def self.fetch_meet_dates(meet)
    Rails.logger.info("Fetching event dates for meet with ID #{meet.usms_meet_id}")
    url = File.join(BASE_URL, '/meets/event_order.cfm')
    params = { smid: meet.club_assistant_meet_id }
    response = RestClient.get(url, params: params)
    page = Nokogiri::HTML(response)

    tables = page.css('table')
    date_table = tables[0]
    event_tables = tables[1..-1]
    dates = date_table.css('tr').map { |tr| tr.css('td')[0].text }

    event_tables.each_with_index do |table, i|
      trs = table.css('tbody tr')
      trs.each do |tr|
        tds = tr.css('td')
        sex = tds[1].text.strip
        stroke = tds[3].text.strip
        if %w(Men Women Mixed).include?(sex) && !stroke.include?('Relay')
          distance = tds[2].text.strip.to_i
          relation = meet.results.joins(:swimmer, :event).where(
            'events.distance' => distance,
            'events.stroke' => stroke
          )
          if sex != 'Mixed'
            relation = relation.where('swimmers.gender' => sex[0])
          end
          relation.update_all(date: dates[i])
        end
      end
    end
  end
end
