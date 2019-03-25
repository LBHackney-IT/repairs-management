require 'rails_helper'

describe HackneyAPI::RepairsClient do
  let(:base_url) { 'https://example.com' }
  let(:api_version) { 'v1' }
  let(:api_client) { described_class.new(base_url: base_url) }
  let(:reference) { 1 }
  let(:empty_response_body) { {} }
  let(:postcode) { 1 }
  let(:address) { "1 Somewhere" }

  describe '#get_work_orders' do
    subject { api_client.get_work_orders }

    context 'successful response' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/work_orders, {}, 500, #{response_body}")
      end
    end
  end

  describe '#get_work_order' do
    subject { api_client.get_work_order(reference) }

    context 'successful response' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/work_orders/#{reference}, {}, 500, #{response_body}")
      end
    end
  end

  describe '#get_work_orders_by_references' do
    it 'fetches multiple work orders' do
      json = '[{ "some": "stuff" }]'
      stub_request(:get, "#{base_url}/#{api_version}/work_orders/by_references?reference=a&reference=b").to_return(status: 200, body: json)

      expect(api_client.get_work_orders_by_references(['a', 'b'])).to eq([{"some" => "stuff"}])
    end

    it 'raises if the references are not found' do
      json = <<-JSON
        {
          "developerMessage": "Exception of type 'HackneyRepairs.Actions.MissingWorkOrderException' was thrown.",
          "userMessage": "Could not find one or more of the given work orders"
        }
      JSON

      stub_request(:get, "#{base_url}/#{api_version}/work_orders/by_references?reference=a").to_return(status: 404, body: json)

      expect { api_client.get_work_orders_by_references(['a']) }.to(
        raise_error(described_class::RecordNotFoundError).
          with_message("#{api_version}/work_orders/by_references, {:reference=>[\"a\"]}")
      )
    end
  end

  describe '#get_repair_request' do
    subject { api_client.get_repair_request(reference) }

    context 'successful response' do
      before { stub_request(:get, "#{base_url}/#{api_version}/repairs/#{reference}").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/repairs/#{reference}").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/#{api_version}/repairs/#{reference}").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/repairs/#{reference}, {}, 500, #{response_body}")
      end
    end
  end

  describe '#get_property' do
    subject { api_client.get_property(reference) }

    context 'successful response' do
      before { stub_request(:get, "#{base_url}/#{api_version}/properties/#{reference}").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/properties/#{reference}").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/#{api_version}/properties/#{reference}").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/properties/#{reference}, {}, 500, #{response_body}")
      end
    end
  end

  describe '#get_properties_by_references' do
    it 'fetches multiple properties' do
      json = '[{ "some": "stuff" }]'
      stub_request(:get, "#{base_url}/#{api_version}/properties/by_references?reference=a&reference=b").to_return(status: 200, body: json)

      expect(api_client.get_properties_by_references(['a', 'b'])).to eq([{"some" => "stuff"}])
    end

    it 'raises if the references are not found' do
      json = <<-JSON
        {
          "developerMessage": "Exception of type 'HackneyRepairs.Actions.MissingWorkOrderException' was thrown.",
          "userMessage": "Could not find one or more of the given properties"
        }
      JSON

      stub_request(:get, "#{base_url}/#{api_version}/properties/by_references?reference=a").to_return(status: 404, body: json)

      expect { api_client.get_properties_by_references(['a']) }.to(
        raise_error(described_class::RecordNotFoundError).
          with_message("#{api_version}/properties/by_references, {:reference=>[\"a\"]}")
      )
    end
  end

  describe '#get_work_order_appointments' do
    subject { api_client.get_work_order_appointments(reference) }

    context 'successful response' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}/appointments").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}/appointments").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}/appointments").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/work_orders/#{reference}/appointments, {}, 500, #{response_body}")
      end
    end
  end

  describe '#get_work_order_appointments_latest' do
    subject { api_client.get_work_order_appointments_latest(reference) }

    context 'successful response' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}/appointments/latest").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}/appointments/latest").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}/appointments/latest").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/work_orders/#{reference}/appointments/latest, {}, 500, #{response_body}")
      end
    end
  end

  describe '#get_work_order_notes' do
    subject { api_client.get_work_order_notes(reference) }

    context 'successful response' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}/notes").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}/notes").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/#{api_version}/work_orders/#{reference}/notes").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/work_orders/#{reference}/notes, {}, 500, #{response_body}")
      end
    end
  end

  describe '#get_property_hierarchy' do
    subject { api_client.get_property_hierarchy(reference) }

    context 'successful response' do
      before { stub_request(:get, "#{base_url}/#{api_version}/properties/#{reference}/hierarchy").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/properties/#{reference}/hierarchy").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/#{api_version}/properties/#{reference}/hierarchy").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/properties/#{reference}/hierarchy, {}, 500, #{response_body}")
      end
    end
  end

  describe '#get_property_by_postcode' do
    subject { api_client.get_property_by_postcode(postcode) }

    context 'successful response' do
      before { stub_request(:get, "#{base_url}/#{api_version}/properties?postcode=#{postcode}&min_level=8&max_level=2").to_return(body: empty_response_body.to_json) }

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/properties?postcode=#{postcode}&min_level=8&max_level=2").to_return(status: 404) }

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

      before { stub_request(:get, "#{base_url}/#{api_version}/properties?postcode=#{postcode}&min_level=8&max_level=2").to_return(status: 500, body: response_body.to_json) }

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/properties, {:postcode=>1, :min_level=>8, :max_level=>2}, 500, #{response_body}")
      end
    end
  end

  # TODO: check if this make any sense
  describe '#get_property_by_address' do
    subject { api_client.get_property_by_address(address, limit: 201) }

    context 'successful response' do
      before do
        stub_request(:get, "#{base_url}/#{api_version}/properties/fladdress")
          .with(query: {address: address, limit: 201, min_level: 8, max_level: 2})
          .to_return(body: empty_response_body.to_json)
      end

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before do
        stub_request(:get, "#{base_url}/#{api_version}/properties/fladdress")
          .with(query: {address: address, limit: 201, min_level: 8, max_level: 2})
          .to_return(status: 404)
      end

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

      before do
        stub_request(:get, "#{base_url}/#{api_version}/properties/fladdress")
          .with(query: {address: address, limit: 201, min_level: 8, max_level: 2})
          .to_return(status: 500, body: response_body.to_json)
      end

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message("#{api_version}/properties/fladdress, {:address=>\"#{address}\", :limit=>201, :min_level=>8, :max_level=>2}, 500, #{response_body}")
      end
    end
  end

  describe '#get_work_orders_by_property' do
    let(:reference) { 'ben_was_here' }
    let(:date_from) { Date.today - 2.years }
    let(:date_to) { Date.tomorrow }

    subject { api_client.get_work_orders_by_property(references: [reference], date_from: date_from, date_to: date_to) }

    context 'successful empty response' do
      before do
        response = []
        stub_request(:get, "#{base_url}/#{api_version}/work_orders?propertyReference=#{reference}&since=#{date_from.strftime("%d-%m-%Y")}&until=#{date_to.strftime("%d-%m-%Y")}")
        .to_return(status: 200, body: response)
      end

      it 'returns empty list when a property has no work orders' do
        expect(subject).to eq([])
      end
    end

    context 'succesful response with information' do
      before do
        response = '[{"sorCode": "HIST0001", "trade": "Cash Items"}]'
        stub_request(:get, "#{base_url}/#{api_version}/work_orders?propertyReference=#{reference}&since=#{date_from.strftime("%d-%m-%Y")}&until=#{date_to.strftime("%d-%m-%Y")}")
        .to_return(status: 200, body: response)
      end

      it 'returns the work orders for a property' do
        response = '[{"sorCode": "HIST0001", "trade": "Cash Items"}]'
        expect(subject).to eq(JSON.parse(response))
      end
    end
  end

  describe '#get_property_block_work_orders_by_trade' do
    let(:trade) { 'trade' }
    let(:date_from) { '01-01-2018' }
    let(:date_to) { '01-02-2018' }

    subject { api_client.get_property_block_work_orders_by_trade(reference: reference, trade: trade, date_from: date_from, date_to: date_to) }

    context 'successful response' do
      before do
        stub_request(:get, "#{base_url}/#{api_version}/properties/#{reference}/block/work_orders?trade=#{trade}&since=#{date_from}&until=#{date_to}")
          .to_return(body: empty_response_body.to_json)
        end

      it 'returns successful response body' do
        expect(subject).to eq(empty_response_body)
      end
    end

    context 'not found error' do
      before { stub_request(:get, "#{base_url}/#{api_version}/properties/#{reference}/block/work_orders?trade=#{trade}&since=#{date_from}&until=#{date_to}").to_return(status: 404) }

      it 'returns an empty response' do
        expect(subject).to eq([])
      end
    end

    context 'API general error' do
      let(:response_body) do
        {
          "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
          "userMessage" => "We had some problems processing your request"
        }
      end

      before do
        stub_request(:get, "#{base_url}/#{api_version}/properties/#{reference}/block/work_orders?trade=#{trade}&since=#{date_from}&until=#{date_to}")
          .to_return(status: 500, body: response_body.to_json)
      end

      it 'raises ApiError error' do
        expect { subject }.to raise_error(described_class::ApiError).with_message(
          "#{api_version}/properties/#{reference}/block/work_orders?trade=#{trade}&since=#{date_from}&until=#{date_to}, {}, 500, #{response_body}"
        )
      end
    end
  end

  describe '#post_work_order_note' do

    subject { api_client.post_work_order_note("00000001", "It's all fine") }

    context 'successful response' do
      it 'posts a note' do
        stub_request(:post, "#{base_url}/#{api_version}/notes")
        .with(headers: { "Content-Type" => "application/json-patch+json" },
              body: {
                objectKey: "uhorder",
                objectReference: "00000001",
                text: "It's all fine"}.to_json)
        .to_return(status: 204)

        expect(subject).to eq(nil)
      end
    end
  end
end
