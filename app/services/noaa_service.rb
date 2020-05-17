module NoaaService
  BASE_URL = 'https://tidesandcurrents.noaa.gov/api/datagetter'
  STATION = '9414750'
  TIME_ZONE = ActiveSupport::TimeZone.new('America/Los_Angeles').freeze

  def self.fetch_tides
    now = TIME_ZONE.now

    params = {
      product: 'predictions',
      begin_date: now.strftime("%Y%m%d"),
      end_date: now.days_since(2).strftime("%Y%m%d"),
      datum: 'MLLW',
      station: STATION,
      time_zone: 'lst_ldt',
      units: 'english',
      interval: 'hilo',
      format: 'json',
    }

    response = RestClient.get(BASE_URL, params: params)
    parsed_response = JSON.parse(response.body)
    parsed_response['predictions'].map do |prediction|
      {
        time: TIME_ZONE.parse(prediction['t']),
        height_in_ft: prediction['v'].to_f,
        type: prediction['type']
      }
    end
  end
end
