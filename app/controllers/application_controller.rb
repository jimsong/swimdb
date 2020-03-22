class ApplicationController < ActionController::API
  before_action :verify_slack_signature

  # See https://api.slack.com/docs/verifying-requests-from-slack
  def verify_slack_signature
    secret = Rails.application.credentials.slack[:signing_secret]
    version = 'v0'
    timestamp = request.headers['X-Slack-Request-Timestamp']
    signature = request.headers['X-Slack-Signature'] || ''

    data = "#{version}:#{timestamp}:#{request.raw_post}"
    calculated_signature =
      'v0=' + OpenSSL::HMAC.hexdigest('SHA256', secret, data)

    return if signature == calculated_signature

    head :unauthorized
  end

end
