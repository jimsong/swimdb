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

    text = "Next high tide is at *#{next_high_tide[:time].strftime("%l:%M %p")}*\n"
    current_date = nil
    tide_data.each do |tide|
      tide_date = tide[:time].to_date
      if current_date != tide_date
        text += "\n*#{tide[:time].strftime("%A, %-m/%-d")}*\n"
        current_date = tide_date
      end
      text += "#{tide[:type] == 'H' ? 'High' : 'Low'} tide at #{tide[:time].strftime("%l:%M %p").strip}\n"
    end
    text += "\n<https://tidesandcurrents.noaa.gov/waterlevels.html?id=9414750&timezone=LST%2FLDT|More information>"

    render json: {
      response_type: 'ephemeral',
      text: text,
    }
  end

  def watertemp
    temp = NoaaService.fetch_temperature

    text = <<~HEREDOC
      Current water temperature in Alameda is *#{temp} °F*
      <https://tidesandcurrents.noaa.gov/physocean.html?id=9414750&timezone=LST%2FLDT|More information>
    HEREDOC

    render json: {
      response_type: 'ephemeral',
      text: text,
    }
  end

  def kitecam
    url = 'https://boardsportscalifornia.com/weather1/webcam/'
    render json: {
      reponse_type: 'ephemeral',
      text: url,
    }
  end

  def wind
    image_url = "https://boardsportscalifornia.com/boardsportscalifornia.com/windreport.png?#{Time.now.to_i}"

    render json: {
      reponse_type: 'ephemeral',
      text: image_url,
      # attachments: [
      #   {
      #     fallback: "test",
      #     color: "#FF8000",
      #     pretext: "This is optional pretext that shows above the attachment.",
      #     text: "This is the text of the attachment. It should appear just above an image of the Mattermost logo. The left border of the attachment should be colored orange, and below the image it should include additional fields that are formatted in columns. At the top of the attachment, there should be an author name followed by a bolded title. Both the author name and the title should be hyperlinks.",
      #     author_name: "Mattermost",
      #     author_icon: "http://www.mattermost.org/wp-content/uploads/2016/04/icon_WS.png",
      #     author_link: "http://www.mattermost.org/",
      #     title: "Example Attachment",
      #     title_link: "http://docs.mattermost.com/developer/message-attachments.html",
      #     fields: [
      #       {
      #         short: false,
      #         title:"Long Field",
      #         value:"Testing with a very long piece of text that will take up the whole width of the table. And then some more text to make it extra long."
      #       },
      #       {
      #         short:true,
      #         title:"Column One",
      #         value:"Testing"
      #       },
      #       {
      #         short:true,
      #         title:"Column Two",
      #         value:"Testing"
      #       },
      #       {
      #         short:false,
      #         title:"Another Field",
      #         value:"Testing"
      #       }
      #     ],
      #     image_url: "http://www.mattermost.org/wp-content/uploads/2016/03/logoHorizontal_WS.png",
      #     image_url: 'https://boardsportscalifornia.com/boardsportscalifornia.com/windreport.png?1589935621540'
      #   }
      #]
    }
  end

end
