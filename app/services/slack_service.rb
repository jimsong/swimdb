class SlackService
  BASE_URL = 'https://slack.com/api/chat.postMessage'
  JIMMY_TEST = 'CS1SBMSRL'
  POOL_SWIMMING = 'C0172JTL98S'
  POOL_NOTIFICATIONS = 'C017LAXUV7G'

  def self.access_token
    Rails.application.credentials.slack[:bot_access_token]
  end

  def self.send_message(channel_id, text)
    payload = {
      channel: channel_id,
      text: text
    }
    RestClient.post(BASE_URL, payload, {Authorization: "Bearer #{access_token}"})
  end

end
