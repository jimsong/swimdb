class CommandsController < ApplicationController

  def run
    Rails.logger.warn(params)
    head :ok
  end

end
