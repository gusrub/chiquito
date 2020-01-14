class ShortUrlsController < ApplicationController
  skip_forgery_protection

  before_action :set_short_url, only: [:show]

  def top
    # let the user request certain amount but not above our system-wide max
    max = params[:max].try(:to_i) || ENV['MAX_TOP_RECORDS'].to_i
    max = if max > ENV['MAX_TOP_RECORDS'].to_i
            ENV['MAX_TOP_RECORDS'].to_i
          else
            max
          end

    @short_urls = ShortUrl.top_visited(max: max)
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
