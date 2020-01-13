class ApplicationController < ActionController::Base

  def index
    render 'short_urls/index'
  end

end
