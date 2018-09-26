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

  describe '#get_work_order_appointments_latest' do
    subject { api_client.get_work_order_appointments_latest(reference) }

    context 'successfull response' do
      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}/appointments/latest").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}/appointments/latest").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/v1/work_orders/#{reference}/appointments/latest").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("v1/work_orders/#{reference}/appointments/latest, 500, #{response_body}")
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

  describe '#get_property_hierarchy' do
    subject { api_client.get_property_hierarchy(reference) }

    context 'successfull response' do
      before { stub_request(:get, "#{base_url}/v1/properties/#{reference}/hierarchy").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/v1/properties/#{reference}/hierarchy").to_return(status: 404) }

      it 'raises RecordNotFoundError error' do
        expect { subject }.to raise_error(described_class::RecordNotFoundError)
      end
    end

    context 'API general error' do
      let(:response_body) do
        {
          'developerMessage' => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
          'userMessage' => 'We had some problems processing your request'
        }
      end

      before { stub_request(:get, "#{base_url}/v1/properties/#{reference}/hierarchy").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("v1/properties/#{reference}/hierarchy, 500, #{response_body}")
      end
    end
  end

  describe '#get_property_by_postcode' do
    subject { api_client.get_property_by_postcode(reference) }

    context 'successfull response' do
      before { stub_request(:get, "#{base_url}/v1/properties?postcode=#{reference}").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/v1/properties?postcode=#{reference}").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/v1/properties?postcode=#{reference}").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("v1/properties?postcode=#{reference}, 500, #{response_body}")
      end
    end
  end

  describe '#get_work_orders_by_property' do
    it 'returns empty list when a property has no work orders' do
      response = []
      stub_request(:get, "#{base_url}/v1/work_orders?propertyReference=ben_was_here").to_return(status: 200, body: response)

      expect(api_client.get_work_orders_by_property("ben_was_here")).to eq([])
    end

    it 'returns the work orders for a property' do
      response = '[{"sorCode": "HIST0001", "trade": "Cash Items"}]'
      stub_request(:get, "#{base_url}/v1/work_orders?propertyReference=ben_was_here").to_return(status: 200, body: response)

      expect(api_client.get_work_orders_by_property("ben_was_here")).to eq(JSON.parse(response))
    end
  end
end
