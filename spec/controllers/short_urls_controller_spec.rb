require 'rails_helper'

RSpec.describe ShortUrlsController, type: :controller do
  describe "GET #top" do
    let(:params) { { format: :json } }
    let!(:urls) { FactoryBot.create_list(:short_url, 10) }
    subject { get :top, params: params }

    it 'returns a successful response' do
      subject
      expect(response.code).to eq('200')
      expect(json.count).to eq(urls.count)
    end
  end

  describe 'POST #create' do
    let(:params) { { short_url: { original: 'https://example.org'}, format: :json } }
    subject { post :create, params: params }

    it 'returns a successful response' do
      subject
      expect(response.code).to eq('201')
      expect(json['id']).to be_present
    end
  end

  describe 'GET #show' do
    let(:short_url) { FactoryBot.create(:short_url) }
    let(:params) { { id: short_url.id, format: :json } }
    subject { get :show, params: params }

    it 'returns a success response' do
      subject
      expect(response.code).to eq('200')
      expect(json['id']).to eq(short_url.id)
    end
  end
end
