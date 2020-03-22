Slack.configure do |config|
  config.token = Rails.application.credentials.slack[:bot_access_token]
end
