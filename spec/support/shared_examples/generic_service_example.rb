RSpec.shared_examples 'service with error' do
  it 'returns false' do
    expect(service.perform).to be false
  end

  it 'generates an errors array' do
    expect { service.perform }.to change { service.errors }
  end

  it 'does not raise an error' do
    expect { service.perform }.to_not raise_error
  end

  it 'has specific error message' do
    service.perform
    expect(service.errors).to include(error_message)
  end
end

RSpec.shared_examples 'successful service' do
  it 'returns true' do
    expect(service.perform).to be true
  end

  it 'does not contain errors' do
    expect { service.perform }.to_not change { service.errors }
  end
end

RSpec.shared_examples 'service with messages' do
  it 'returns true' do
    expect(service.perform).to be true
  end

  it 'does not contain errors' do
    expect { service.perform }.to_not change { service.errors }
  end

  it 'has specific message' do
    service.perform
    expect(service.messages).to include(message)
  end
end
