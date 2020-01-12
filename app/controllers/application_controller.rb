class ApplicationController < ActionController::Base
  def version
    render json: { ping: 'pong' }
  end
end
