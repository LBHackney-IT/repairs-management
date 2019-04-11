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

  it "fails when data is bad" do
    stub_request(:post, "https://hackneyrepairs/v1/repairs").with(
      headers: {
        "Content-Type" => "application/json-patch+json"
      },
      body: {
        "contact": {
          "name": "",
          # FIXME: must fix view logic inside model
          "telephoneNumber": "N/A",
        },
        "workOrders": [
          "sorCode": "",
        ],
        "priority": "G",
        "propertyReference": "00000018",
        "problemDescription": ""
      }.to_json
    ).to_return(
      status: 400,
      body: [
        {
          "developerMessage" => "Please provide a valid Problem",
          "userMessage" => "Please provide a valid Problem"
        },
        {
          "developerMessage" => "If Repair request has workOrders you must provide a valid sorCode",
          "userMessage" => "If Repair request has workOrders you must provide a valid sorCode"
        },
        {
          "developerMessage" => "Contact Name cannot be empty",
          "userMessage" => "Contact Name cannot be empty"
        },
        {
          "developerMessage" => "Telephone number must contain minimum of 10 and maximum of 11 digits.",
          "userMessage" => "Telephone number must contain minimum of 10 and maximum of 11 digits."
        }
      ].to_json
    )

    repair_request = Hackney::RepairRequest.new(
      contact_attributes: {
        name: "",
        telephone_number: ""
      },
      work_orders_attributes: [
        { sor_code: "" }
      ],
      priority: "G",
      property_reference: "00000018",
      description: ""
    )

    expect(repair_request.save).to be_falsey

    expect(repair_request.reference).not_to be_present

    expect(repair_request.errors.include?("contact.name")).to be_truthy
    expect(repair_request.contact.errors.include?("name")).to be_truthy

    expect(repair_request.errors.include?("contact.telephone_number")).to be_truthy
    expect(repair_request.contact.errors.include?("telephone_number")).to be_truthy

    expect(repair_request.errors.include?("work_orders[0].sor_code")).to be_truthy
    expect(repair_request.work_orders[0].errors.include?("sor_code")).to be_truthy

    expect(repair_request.errors.include?("description")).to be_truthy
  end
end
