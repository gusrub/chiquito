class ApplicationController < ActionController::Base

  def index
    render 'short_urls/index'
  end

  def reroute
    path = params[:path]
    url = ShortUrl.find_by(short: path)

    if url.present?
      redirect_to url.original, status: 303
    else
      redirect_to :index
    end
  end
end
