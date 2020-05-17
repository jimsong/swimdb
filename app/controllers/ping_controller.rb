class PingController < ApplicationController

  def ping
    render json: { status: 'ok' }
  end

end
