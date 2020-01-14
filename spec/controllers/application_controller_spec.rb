require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'GET #reroute' do
    let!(:url) { FactoryBot.create(:short_url) }
    let(:params) { { format: :json, path: url.short } }
    subject { get :reroute, params: params }

    it 'bumps visit count' do
      expect { subject }.to change { url.reload.visit_count }
    end
  end
end
