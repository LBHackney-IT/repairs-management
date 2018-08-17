require 'rails_helper'

describe HackneyAPI::RepairsClient do
  let(:base_url) { 'https://example.com' }
  let(:api_client) { described_class.new(base_url: base_url) }
  let(:reference) { 1 }
  let(:empty_response_body) { {} }

  describe '#get_work_orders' do
    subject { api_client.get_work_orders }

    context 'successfull response' do
      before { stub_request(:get, "#{base_url}/v1/work_orders").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/v1/work_orders").to_return(status: 404) }

      it 'raises RecordNotFoundError error' do
        expect { subject }.to raise_error(described_class::RecordNotFoundError)
      end
    end

    context 'API general error' do
      let(:response_body) do
        {
          "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
          "userMessage" => "We had some problems processing your request"
        }
      end

      before { stub_request(:get, "#{base_url}/v1/work_orders").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("v1/work_orders, 500, #{response_body}")
      end
    end
  end

  describe '#get_work_order' do
    subject { api_client.get_work_order(reference) }

    context 'successfull response' do
      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}").to_return(status: 404) }

      it 'raises RecordNotFoundError error' do
        expect { subject }.to raise_error(described_class::RecordNotFoundError)
      end
    end

    context 'API general error' do
      let(:response_body) do
        {
          "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
          "userMessage" => "We had some problems processing your request"
        }
      end

      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("v1/work_orders/#{reference}, 500, #{response_body}")
      end
    end
  end

  describe '#get_repair_request' do
    subject { api_client.get_repair_request(reference) }

    context 'successfull response' do
      before { stub_request(:get, "#{base_url}/v1/repairs/#{reference}").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/v1/repairs/#{reference}").to_return(status: 404) }

      it 'raises RecordNotFoundError error' do
        expect { subject }.to raise_error(described_class::RecordNotFoundError)
      end
    end

    context 'API general error' do
      let(:response_body) do
        {
          "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
          "userMessage" => "We had some problems processing your request"
        }
      end

      before { stub_request(:get, "#{base_url}/v1/repairs/#{reference}").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("v1/repairs/#{reference}, 500, #{response_body}")
      end
    end
  end

  describe '#get_property' do
    subject { api_client.get_property(reference) }

    context 'successfull response' do
      before { stub_request(:get, "#{base_url}/v1/properties/#{reference}").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/v1/properties/#{reference}").to_return(status: 404) }

      it 'raises RecordNotFoundError error' do
        expect { subject }.to raise_error(described_class::RecordNotFoundError)
      end
    end

    context 'API general error' do
      let(:response_body) do
        {
          "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
          "userMessage" => "We had some problems processing your request"
        }
      end

      before { stub_request(:get, "#{base_url}/v1/properties/#{reference}").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("v1/properties/#{reference}, 500, #{response_body}")
      end
    end
  end

  describe '#get_work_order_appointments' do
    subject { api_client.get_work_order_appointments(reference) }

    context 'successfull response' do
      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}/appointments").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}/appointments").to_return(status: 404) }

      it 'raises RecordNotFoundError error' do
        expect { subject }.to raise_error(described_class::RecordNotFoundError)
      end
    end

    context 'API general error' do
      let(:response_body) do
        {
          "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
          "userMessage" => "We had some problems processing your request"
        }
      end

      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}/appointments").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("v1/work_orders/#{reference}/appointments, 500, #{response_body}")
      end
    end
  end

  describe '#get_work_order_notes' do
    subject { api_client.get_work_order_notes(reference) }

    context 'successfull response' do
      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}/notes").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}/notes").to_return(status: 404) }

      it 'raises RecordNotFoundError error' do
        expect { subject }.to raise_error(described_class::RecordNotFoundError)
      end
    end

    context 'API general error' do
      let(:response_body) do
        {
          "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
          "userMessage" => "We had some problems processing your request"
        }
      end

      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}/notes").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("v1/work_orders/#{reference}/notes, 500, #{response_body}")
      end
    end
  end
end
