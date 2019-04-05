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

describe Hackney::RepairRequest, '#save' do
  it 'creates a repair request' do
    stub_request(:post, "https://hackneyrepairs/v1/repairs").with(
      headers: {
        "Content-Type" => "application/json-patch+json"
      },
      body: {
        "contact": {
          "name": "blablabla",
          "telephoneNumber": "01234567890",
        },
        "workOrders": [
          "sorCode": "08500820",
        ],
        "priority": "G",
        "propertyReference": "00000018",
        "problemDescription": "it's broken fix it"
      }.to_json
    ).to_return(
      status: 200,
      body: {
        "repairRequestReference" => "03210303",
        "propertyReference" =>"00000018",
        "problemDescription" => "it's broken fix it",
        "priority" => "G",
        "contact" => {
          "name" => "blablabla",
          "telephoneNumber" => "01234567890"
        },
        "workOrders"=> [
          {
            "workOrderReference" => "01552718",
            "sorCode" => "08500820",
            "supplierReference" => "H01"
          }
        ]
      }.to_json
    )

    repair_request = Hackney::RepairRequest.new(
      contact_attributes: {
        name: "blablabla",
        telephone_number: "01234567890"
      },
      work_orders_attributes: [
        { sor_code: "08500820" }
      ],
      priority: "G",
      property_reference: "00000018",
      description: "it's broken fix it"
    )

    repair_request.save

    expect(repair_request).to be_a(Hackney::RepairRequest)
    expect(repair_request.reference).to be_present
    expect(repair_request.contact).to be_a(Hackney::Contact)
  end

  pending "raises when SOR code is bad"
  pending "raises when property is invalid"
  pending "other errors..."
end
