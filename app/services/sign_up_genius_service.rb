class SignUpGeniusService
  BASE_URL = 'https://www.signupgenius.com/go/'
  NBSP = 160.chr(Encoding::UTF_8)

  def initialize(urlid)
    @urlid = urlid
  end

  def url
    File.join(BASE_URL, @urlid)
  end

  def page
    response = RestClient.get(url)
    Nokogiri::HTML(response)
  end

  def open_slots
    inputs = page.css('input').select {|input| input['name'] == 'siid'}
    inputs.map do |input|
      pool_tr = input.parent.parent.parent.parent
      pool = pool_tr.xpath('td')[0].xpath('p')[0].inner_text

      td = input.ancestors.find do |ancestor|
        if ancestor.name == 'td' && ancestor['class'] == 'SUGtable'
          ancestor
        end
      end
      tr = td.parent
      time = tr.xpath('td')[-2].xpath('span')[0].text.gsub(NBSP, '').strip

      date = nil
      rows = tr.parent.children.select {|child| child.name == 'tr' }
      index = rows.find_index {|row| row == tr}
      while index > 0
        tds = rows[index].children.select {|child| child.name == 'td'}
        if tds.count > 2
          date = tds[0].xpath('span')[0].text
          break
        end
        index -= 1
      end
      { time: time, date: date, pool: pool }
    end
  end

end
