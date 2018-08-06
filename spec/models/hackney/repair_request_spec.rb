require 'rails_helper'

describe Hackney::RepairRequest, '#build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds a repair request from the API response' do
    model = described_class.build(repair_request_response_payload)

    expect(model).to be_a(Hackney::RepairRequest)
    expect(model.reference).to eq('03209397')
    expect(model.description).to eq('TEST problem')
    expect(model.contact).to be_a(Hackney::Contact)
  end

  it 'builds the contact attribute when empty' do
    model = described_class.build(
      repair_request_response_payload.except('contact')
    )

    expect(model.contact).to be_a(Hackney::Contact)
  end
end

describe Hackney::RepairRequest, '#find' do
  include Helpers::HackneyRepairsRequestStubs

  it 'finds a repair request' do
    stub_hackney_repairs_repair_requests

    repair_request = described_class.find('03209397')

    expect(repair_request).to be_a(Hackney::RepairRequest)
    expect(repair_request.reference).to eq('03209397')

    expect(repair_request.contact).to be_a(Hackney::Contact)
    expect(repair_request.contact.name).to eq('MR SULEYMAN ERBAS')
  end

  it 'raises a RecordNotFound error when a repair request cannot be found' do
    stub_hackney_repairs_repair_requests(status: 404)

    expect {
      described_class.find('03209397')
    }.to raise_error HackneyAPI::RepairsClient::RecordNotFoundError
  end

  it 'raises an error when the API fails to retrieve a repair request' do
    stub_hackney_repairs_repair_requests(status: 500)

    expect {
      described_class.find('03209397')
    }.to raise_error HackneyAPI::RepairsClient::ApiError
  end

end
