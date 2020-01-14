require "rails_helper"

RSpec.describe ShortUrlsController, type: :routing do
  describe 'routing' do
    let(:short_url) { FactoryBot.create(:short_url) }
    it 'routes to #create' do
      expect(:post => "/short_urls").to route_to("short_urls#create", :format => 'json')
    end

    it 'routes to #show' do
      expect(:get => "/short_urls/1").to route_to('short_urls#show', :id => '1', :format=> 'json')
    end

    it 'routes to #top' do
      expect(:get => "/short_urls/top").to route_to('short_urls#top', :format=> 'json')
    end

    it 'routes main route to the single view' do
      expect(:get => "/").to route_to('application#index')
    end

    it 'routes everything else to the redirection' do
      expect(:get => "/#{short_url.short}").to route_to('application#reroute', path: short_url.short)
    end
  end
end
