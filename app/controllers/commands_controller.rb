class CommandsController < SlackController

  def swimdb
    Rails.logger.warn(params)
    head :ok
  end

  def tides
    tide_data = NoaaService.fetch_tides
    next_high_tide = tide_data.find do |tide|
      tide[:time] > Time.now && tide[:type] == 'H'
    end

    upcoming_tides_text = ""
    current_date = nil
    tide_data.each do |tide|
      tide_date = tide[:time].to_date
      if current_date != tide_date
        upcoming_tides_text += "\n*#{tide[:time].strftime("%A, %-m/%-d")}*\n"
        current_date = tide_date
      end
      upcoming_tides_text += "#{tide[:type] == 'H' ? 'High' : 'Low'} tide at #{tide[:time].strftime("%l:%M %p").strip}\n"
    end

    render json: {
      response_type: 'ephemeral',
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: "Next high tide is at *#{next_high_tide[:time].strftime("%l:%M %p")}*"
          }
        },
        {
          type: 'divider'
        },
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: upcoming_tides_text.strip
          }
        }
      ]
    }
  end

  def watertemp
    temp = NoaaService.fetch_temperature
    render json: {
      response_type: 'ephemeral',
      text: "Current water temperature in Alameda is *#{temp} °F*"
    }
  end

end
