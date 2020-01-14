require 'rails_helper'

RSpec.describe ShortUrlsController, type: :controller do
  describe 'GET #top' do
    let(:max) { ENV['MAX_TOP_RECORDS'].to_i }
    let(:params) { { format: :json } }
    let!(:urls) { FactoryBot.create_list(:short_url, max+1) }
    subject { get :top, params: params }

    context 'if no max number is given' do
      it 'returns the default top max' do
        subject
        expect(json.count).to eq(max)
      end
    end

    context 'if a max number is given' do
      let(:params) { {format: :json, max: max-1} }
      it 'returns the default top requested' do
        subject
        expect(json.count).to eq(max-1)
      end
    end

    describe 'ordered by visitor count' do
      let!(:top_url) { FactoryBot.create(:short_url, visit_count: 100) }

      it 'pulls records ordered by visitor count descending' do
        subject
        expect(json.first['id']).to eq(top_url.id)
        expect(json.first['visit_count']).to eq(100)
      end
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
