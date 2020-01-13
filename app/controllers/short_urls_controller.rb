class ShortUrlsController < ApplicationController
  skip_forgery_protection

  before_action :set_short_url, only: [:show]

  def top
    @short_urls = ShortUrl.all
  end

  def show
  end

  def create
    @short_url = ShortUrl.new(short_url_params)
    if @short_url.save
      render :show, status: :created, location: @short_url
    else
      render json: @short_url.errors, status: :unprocessable_entity
    end
  end

  private

  def set_short_url
    @short_url = ShortUrl.find(params[:id])
  end

  def short_url_params
    params.require(:short_url)
          .permit(:original, :short, :expiration, :title)
          .merge({ip_address: request.remote_ip})
  end
end
