require 'rails_helper'

describe PullUrlTitleService do
  let(:url) { 'http://example.com' }
  let(:title) { 'Hello world!' }
  let(:response) { "<html><head><title>#{title}</title></head></html>" }
  let(:service) { described_class.new(url) }

  context 'when URL is unavailable' do
    let(:error_message) { 'Could not connect to host' }

    before(:each) do
      allow(Net::HTTP)
        .to receive(:get)
        .and_raise(SocketError, "you can't have a pony!")
    end

    it_behaves_like 'service with error'
  end

  context 'when title is not available' do
    let(:message) { "Tried to pull title from #{url} but it seems to be empty" }
    let(:title) { nil }

    before(:each) do
      allow(Net::HTTP)
        .to receive(:get)
        .and_return(response)
    end

    it_behaves_like 'service with messages'
  end

  context 'when title is available' do
    before(:each) do
      allow(Net::HTTP)
        .to receive(:get)
        .and_return(response)
    end

    it_behaves_like 'successful service'

    it 'pulls the actual title' do
      expect { service.perform }.to change { service.output }.to(title)
    end
  end

end
