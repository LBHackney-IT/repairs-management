require 'rails_helper'

describe HackneyAPI::RepairsClient do
  let(:base_url) { 'https://example.com' }
  let(:api_client) { described_class.new(base_url: base_url) }

  describe '#request' do
    context 'GET method' do
      context '404 response code' do
        before { stub_request(:get, 'https://example.com/endpoint').to_return(status: 404) }

        it 'raises a RecordNotFoundError error when a resource is not found' do
          expect { api_client.request(http_method: :get, endpoint: 'endpoint') }.to raise_error HackneyAPI::RepairsClient::RecordNotFoundError
        end
      end

      context '500 response code' do
        let(:response_body) do
          {
            'developerMessage' => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
            'userMessage' => 'We had some problems processing your request'
          }
        end

        before { stub_request(:get, 'https://example.com/endpoint').to_return(status: 500, body: response_body.to_json) }

        it 'raises a ApiError error when the response errors' do
          expect { api_client.request(http_method: :get, endpoint: 'endpoint') }.to raise_error(HackneyAPI::RepairsClient::ApiError)
            .with_message("endpoint, 500, #{response_body}")
        end
      end

      context 'timeout response' do
        before { stub_request(:get, 'https://example.com/endpoint').to_timeout }

        it 'raises a ApiError error after a request timeout' do
          expect { api_client.request(http_method: :get, endpoint: 'endpoint') }.to raise_error(HackneyAPI::RepairsClient::ApiError)
            .with_message(/execution expired/)
        end
      end

      context 'URL contact' do
        let(:base_url) { 'https://example.com/foo' }
        let(:response_body) { {} }

        before { stub_request(:get, 'https://example.com/foo/bar/baz').to_return(status: 200, body: response_body.to_json) }

        it 'concatenates the full URL' do
          expect(api_client.request(http_method: :get, endpoint: 'bar/baz')).to eq(response_body)
        end
      end

      context 'URL replacement' do
        let(:base_url) { 'https://example.com/foo' }
        let(:response_body) { {} }

        before { stub_request(:get, 'https://example.com/bar/baz').to_return(status: 200, body: response_body.to_json) }

        it 'replaces the subpath defined from base_url' do
          expect(api_client.request(http_method: :get, endpoint: '/bar/baz')).to eq(response_body)
        end
      end
    end
  end
end
