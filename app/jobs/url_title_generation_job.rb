class UrlTitleGenerationJob < ApplicationJob
  queue_as :default

  def perform(short_url_id)
    short_url = ShortUrl.find(short_url_id)
    return true if short_url.title.present?

    service = PullUrlTitleService.new(short_url.original)
    if service.perform
      short_url.update_attributes(title: service.output)
    end
  end
end
