require 'rails_helper'

describe Hackney::WorkOrder, '#build' do
  it 'builds a work order for a given work order reference' do
    api_response = {
      "wo_ref" => "01572924",
      "prop_ref" => "00003182",
      "rq_ref" => "03249135",
      "created" => "2018-07-26T10:42:12Z"
    }

    stub_request(:get, "https://hackneyrepairs/v1/workorders/01572924")
      .to_return(status: 200, body: api_response.to_json)

    model = described_class.new('01572924').build
    expect(model.reference).to eq('01572924')
  end

  it 'raises a not found error when the resource is not found' do
    stub_request(:get, "https://hackneyrepairs/v1/workorders/00000000")
      .to_return(status: 404)

    expect {
      described_class.new('00000000').build
    }.to raise_error Hackney::WorkOrder::RecordNotFound
  end

  it 'raises a generic error when the api returns a server error' do
    stub_request(:get, "https://hackneyrepairs/v1/workorders/12345678")
      .to_return(status: 500)

    expect {
      described_class.new('12345678').build
    }.to raise_error Hackney::WorkOrder::Error
  end
end
