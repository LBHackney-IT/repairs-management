require 'rails_helper'

describe HackneyRepairsClient, '#get' do
  include Helpers::HackneyRepairsRequestStubs

  it 'raises a RecordNotFound error when a resource is not found' do
    stub_request(:get, 'https://example.com/endpoint').to_return(status: 404)

    client = described_class.new(base_url: 'https://example.com')

    expect { client.get('endpoint') }.to raise_error HackneyRepairsClient::RecordNotFound
  end

  it 'raises a generic error when the response errors' do
    stub_request(:get, 'https://example.com/endpoint').to_return(status: 500)

    client = described_class.new(base_url: 'https://example.com')

    expect { client.get('endpoint') }.to raise_error HackneyRepairsClient::Error
  end

  it 'raises a generic error after a request timeout' do
    stub_request(:get, 'https://example.com/endpoint').to_timeout

    client = described_class.new(base_url: 'https://example.com')

    expect { client.get('endpoint') }.to raise_error HackneyRepairsClient::Error
  end

  it 'concatenates the full URL' do
    stub = stub_request(:get, 'https://example.com/foo/bar/baz').to_return(status: 200)

    client = described_class.new(base_url: 'https://example.com/foo')
    client.get('bar/baz')

    expect(stub).to have_been_requested
  end

  it 'replaces the subpath defined from base_url' do
    stub = stub_request(:get, 'https://example.com/bar/baz').to_return(status: 200)

    client = described_class.new(base_url: 'https://example.com/foo')
    client.get('/bar/baz')

    expect(stub).to have_been_requested
  end
end
