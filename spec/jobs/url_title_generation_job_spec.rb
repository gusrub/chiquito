require "rails_helper"

RSpec.describe UrlTitleGenerationJob, type: :job do
  describe "#perform_later" do
    let(:short_url) { FactoryBot.create(:short_url) }

    it 'pulls the title for a short URL' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        short_url.save!
      }.to have_enqueued_job
    end
  end
end
