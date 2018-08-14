require 'rails_helper'

describe HackneyAPI::RepairsClient, '#get' do
  include Helpers::HackneyRepairsRequestStubs

  it 'raises a RecordNotFoundError error when a resource is not found' do
    stub_request(:get, 'https://example.com/endpoint').to_return(status: 404)

    client = described_class.new(base_url: 'https://example.com')

    expect { client.request(http_method: :get, endpoint: 'endpoint') }.to raise_error HackneyAPI::RepairsClient::RecordNotFoundError
  end

  it 'raises a generic error when the response errors' do
    response_body = {
      "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
      "userMessage" => "We had some problems processing your request"
    }
    stub_request(:get, 'https://example.com/endpoint').to_return(status: 500, body: response_body.to_json)

    client = described_class.new(base_url: 'https://example.com')

    expect { client.request(http_method: :get, endpoint: 'endpoint') }.to raise_error(HackneyAPI::RepairsClient::ApiError)
      .with_message("endpoint, 500, #{response_body}")
  end

  it 'raises a generic error after a request timeout' do
    stub_request(:get, 'https://example.com/endpoint').to_timeout

    client = described_class.new(base_url: 'https://example.com')

    expect { client.request(http_method: :get, endpoint: 'endpoint') }.to raise_error(HackneyAPI::RepairsClient::ApiError)
      .with_message(/execution expired/)
  end

  it 'concatenates the full URL' do
    stub = stub_request(:get, 'https://example.com/foo/bar/baz').to_return(status: 200)

    client = described_class.new(base_url: 'https://example.com/foo')
    client.request(http_method: :get, endpoint: 'bar/baz')

    expect(stub).to have_been_requested
  end

  it 'replaces the subpath defined from base_url' do
    stub = stub_request(:get, 'https://example.com/bar/baz').to_return(status: 200)

    client = described_class.new(base_url: 'https://example.com/foo')
    client.request(http_method: :get, endpoint: '/bar/baz')

    expect(stub).to have_been_requested
  end
end
