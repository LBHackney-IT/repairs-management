require 'rails_helper'

describe Hackney::Supplier, '.build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds when the API response contains all fields' do
    model = described_class.build(repair_request_response_payload['workOrders'].first)

    expect(model).to be_a(Hackney::Supplier)
    expect(model.supplier_reference).to eq('H09')
  end

  it 'builds when the API response is empty' do
    model = described_class.build({})
    expect(model.supplier_reference).to be_blank
  end
end
