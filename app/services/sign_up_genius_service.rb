class SignUpGeniusService
  BASE_URL = 'https://www.signupgenius.com/go/904044caaa92aa2fa7-soda'
  NBSP = 160.chr(Encoding::UTF_8)

  def initialize(id)
    @id = id
  end

  def url
    BASE_URL + @id.to_s
  end

  def page
    response = RestClient.get(url)
    Nokogiri::HTML(response)
  end

  def open_slots
    inputs = page.css('input').select {|input| input['name'] == 'siid'}
    inputs.map do |input|
      td = input.ancestors.find do |ancestor|
        if ancestor.name == 'td' && ancestor['class'] == 'SUGtable'
          ancestor
        end
      end
      tr = td.parent
      time = tr.children.select {|child| child.name == 'td'}[-2].css('span')[0].text.gsub(NBSP, '').strip

      rows = tr.parent.children.select {|child| child.name == 'tr' }
      index = rows.find_index {|row| row == tr}
      while index > 0
        tds = rows[index].children.select {|child| child.name == 'td'}
        if tds.count > 2
          date = tds[0].children.css('span')[0].text
          break
        end
        index -= 1
      end
      { time: time, date: date }
    end
  end

end
