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
