require 'pry'
require 'rails_helper'

include Helpers::HackneyRepairsRequestStubs

describe Hackney::WorkOrder do
  let(:api_version) { 'v1' }

  describe '.build' do
    it 'builds a work order from the API response' do
      model = described_class.build(work_order_response_payload)

      expect(model.reference).to eq('01551932')
      expect(model.rq_ref).to eq('03209397')
      expect(model.prop_ref).to eq('00014665')
      expect(model.created).to eq DateTime.new(2018, 05, 29, 14, 10, 06)
    end

    it "errors when given an invalid date to parse" do
      attributes = work_order_response_payload.merge('created' => 'null')

      expect {
        described_class.build(attributes)
      }.to raise_error.with_message('invalid date')
    end
  end

  describe '.for_property_block_and_trade' do
    let(:reference) { '121212' }
    let(:trade) { 'trade' }
    let(:date_from) { '01-01-2017' }
    let(:date_to) { '01-01-2018' }

    subject { described_class.for_property_block_and_trade(property_reference: reference, trade: trade, date_to: date_to, date_from: date_from) }

    it 'finds work orders by a property and a trade' do
      stub_hackney_repairs_work_order_block_by_trade(trade: trade, reference: reference, date_to: date_to, date_from: date_from)

      expect(subject.first).to be_an(Hackney::WorkOrder)
      expect(subject.first.prop_ref).to eq(reference)
      expect(subject.first.trade).to eq(trade)
    end

    it 'returns an empty response' do
      stub_hackney_repairs_work_order_block_by_trade(trade: trade, reference: reference, date_to: date_to, date_from: date_from, status: 404)

      expect(subject).to eq([])
    end

    it 'raises an error when the API fails to retrieve a property' do
      stub_hackney_repairs_work_order_block_by_trade(trade: trade, reference: reference, date_to: date_to, date_from: date_from, status: 500)

      expect { subject }.to raise_error(HackneyAPI::RepairsClient::ApiError)
    end
  end

  describe '.for_property_block_and_trade' do
    it 'finds a work order' do
      stub_hackney_repairs_work_orders

      work_order = described_class.find('01551932')

      expect(work_order).to be_a(Hackney::WorkOrder)
      expect(work_order.reference).to eq('01551932')
    end

    it 'raises a RecordNotFound error when a work order cannot be found' do
      stub_hackney_repairs_work_orders(status: 404)

      expect {
        described_class.find('01551932')
      }.to raise_error HackneyAPI::RepairsClient::RecordNotFoundError
    end

    it 'raises an error when the API fails to retrieve a work order' do
      stub_hackney_repairs_work_orders(status: 500)

      expect {
        described_class.find('01551932')
      }.to raise_error HackneyAPI::RepairsClient::ApiError
    end
  end

  describe '#repair' do
    before do
      stub_hackney_repairs_work_orders
    end

    subject { described_class.find('01551932') }

    it 'finds the associated repair' do
      stub_hackney_repairs_repair_requests
      expect(subject.repair_request.reference).to eq('03209397')
      expect(subject.repair_request.contact.name).to eq('MR SULEYMAN ERBAS')
    end

    it 'rescues api errors' do
      stub_hackney_repairs_repair_requests(status: 500)
      expect(subject.repair_request.reference).to be_nil
      expect(subject.repair_request.description).to eq 'Repair info missing'
    end
  end

  describe '#find_all' do
    it 'fetches multiple work orders' do
      stub_hackney_repairs_work_orders_by_reference(references: ["00000001", "00000002"], body: [
        work_order_response_payload("workOrderReference" => "00000001", "propertyReference" => "123"),
        work_order_response_payload("workOrderReference" => "00000002", "propertyReference" => "321"),
      ])

      work_orders = described_class.find_all(["00000001", "00000002"])

      expect(work_orders.size).to eq 2
      expect(work_orders.first.reference).to eq '00000001'
      expect(work_orders.first.prop_ref).to eq '123'
      expect(work_orders.last.reference).to eq '00000002'
      expect(work_orders.last.prop_ref).to eq '321'
    end

    it 'returns [] if the references are not found' do
      stub_hackney_repairs_work_orders_by_reference(status: 404, references: ["00000001"], body: {
        "developerMessage": "Exception of type 'HackneyRepairs.Actions.MissingWorkOrderException' was thrown.",
        "userMessage": "Could not find one or more of the given work orders"
      })

      expect(described_class.find_all(["00000001"])).to eq []
    end
  end

  describe '.feed' do
    let(:status) { 200 }
    let(:body) {
      [
        {
          "workOrderReference" => "00109866",
          "propertyReference" => "00005927",
          "problemDescription" => "Pls refix w/h/b",
          "created" => "2008-10-13T00:00:00"
        }
      ].to_json
    }

    before do
      stub_request(:get, "https://hackneyrepairs/#{api_version}/work_orders/feed?startId=00000000")
        .to_return(status: status, body: body)
    end

    it 'returns work orders' do
      results = described_class.feed('00000000')

      expect(results.size).to eq 1
      expect(results.first.reference).to eq '00109866'
      expect(results.first.prop_ref).to eq '00005927'
      expect(results.first.created).to eq DateTime.civil(2008, 10, 13)
      expect(results.first.problem_description).to eq 'Pls refix w/h/b'
    end

    context 'api error' do
      let(:status) { 500 }

      it 'lets the api error through' do
        expect { described_class.feed('00000000') }.to raise_error(HackneyAPI::RepairsClient::ApiError)
      end
    end
  end
end
