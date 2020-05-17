class CommandsController < ApplicationController

  skip_before_action :verify_slack_signature, only: :ping

  def ping
    render json: {status: 'ok'}
  end

  def run
    Rails.logger.warn(params)
    head :ok
  end

end
