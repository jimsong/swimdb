module UsmsService
  BASE_URL = 'https://usms.org'

  def self.get_swimmer_info(usms_permanent_id)
    url = File.join(BASE_URL, 'people', usms_permanent_id)
    response = RestClient.get(url)
    page = Nokogiri::HTML(response)
    name = page.css(".contenttext div table tr")[1].css("td")[1].text
    name_parts = name.strip.split(/\s+/)
    Swimmer.new(
      usms_permanent_id: usms_permanent_id,
      first_name: name_parts[0...-1].join(" "),
      last_name: name_parts[-1]
    )
  end

end
