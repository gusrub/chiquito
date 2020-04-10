require "rails_helper"

RSpec.describe UrlTitleGenerationJob, type: :job do
  let(:short_url) { FactoryBot.build(:short_url, title: nil) }

  describe "#perform_later" do
    before(:all) do
      ENV['TITLE_PULL_QUEUE'] = "true"
    end

    after(:all) do
      ENV['TITLE_PULL_QUEUE'] = "false"
    end

    it 'puts the title pull in a queue' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        short_url.save!
      }.to have_enqueued_job
    end
  end

  describe "#perform_now" do
    before(:all) do
      ENV['TITLE_PULL_QUEUE'] = "false"
    end

    after(:all) do
      ENV['TITLE_PULL_QUEUE'] = "true"
    end

    it 'doesnt put the title pull on a queue' do
      ActiveJob::Base.queue_adapter = :test
      expect {
        short_url.save!
      }.to_not have_enqueued_job
    end
  end
end
