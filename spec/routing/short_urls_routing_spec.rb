require "rails_helper"

RSpec.describe ShortUrlsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(:post => "/short_urls").to route_to("short_urls#create")
    end

    it 'routes to #show' do
      expect(:get => "/short_urls/1").to route_to('short_urls#show', :id => '1')
    end

    it 'routes to #top' do
      expect(:get => "/short_urls/top").to route_to('short_urls#top')
    end
  end
end
