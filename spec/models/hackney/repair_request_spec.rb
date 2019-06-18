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
        "problemDescription": "it's broken fix it",
        "lbhEmail": "pudding@hackney.gov.uk"
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
      description: "it's broken fix it",
      created_by_email: "pudding@hackney.gov.uk"
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
          { "sorCode": "" },
          { "sorCode": "" }
        ],
        "priority": "G",
        "propertyReference": "00000018",
        "problemDescription": "",
        "lbhEmail": "pudding@hackney.gov.uk"
      }.to_json
    ).to_return(
      status: 400,
      body: [
        {
          "code" => 400,
          "source" => "/problemDescription",
          "developerMessage" => "Problem description cannot be null or empty",
          "userMessage" => "Please provide a valid Problem"
        },
        {
          "code" => 400,
          "source" => "/workOrders/0/sorCode",
          "developerMessage" => "sorCode is invalid",
          "userMessage" => "If Repair request has workOrders you must provide a valid sorCode"
        },
        {
          "code" => 400,
          "source" => "/workOrders/1/sorCode",
          "developerMessage" => "sorCode is invalid",
          "userMessage" => "If Repair request has workOrders you must provide a valid sorCode"
        },
        {
          "code" => 400,
          "source" => "/contact/name",
          "developerMessage" => "Contact Name cannot be empty",
          "userMessage" => "Please provide a name for the contact"
        },
        {
          "code" => 400,
          "source" => "/contact/telephoneNumber",
          "developerMessage" => "Contact Telephone number is invalid",
          "userMessage" => "Telephone number must contain minimum of 10 and maximum of 11 digits"
        }
      ].to_json
    )

    repair_request = Hackney::RepairRequest.new(
      contact_attributes: {
        name: "",
        telephone_number: ""
      },
      work_orders_attributes: [
        { sor_code: "" },
        { sor_code: "" }
      ],
      priority: "G",
      property_reference: "00000018",
      description: "",
      created_by_email: "pudding@hackney.gov.uk"
    )

    expect(repair_request.save).to be_falsey

    expect(repair_request.reference).not_to be_present


    expect(repair_request.errors.added?("contact.name", "Please provide a name for the contact")).to be_truthy
    expect(repair_request.contact.errors.added?("name", "Please provide a name for the contact")).to be_truthy

    expect(repair_request.errors.added?("contact.telephone_number", "Telephone number must contain minimum of 10 and maximum of 11 digits")).to be_truthy
    expect(repair_request.contact.errors.added?("telephone_number", "Telephone number must contain minimum of 10 and maximum of 11 digits")).to be_truthy

    expect(repair_request.errors.added?("work_orders[0].sor_code", "If Repair request has workOrders you must provide a valid sorCode")).to be_truthy
    expect(repair_request.work_orders[0].errors.added?("sor_code", "If Repair request has workOrders you must provide a valid sorCode")).to be_truthy

    expect(repair_request.errors.added?("work_orders[1].sor_code", "If Repair request has workOrders you must provide a valid sorCode")).to be_truthy
    expect(repair_request.work_orders[1].errors.added?("sor_code", "If Repair request has workOrders you must provide a valid sorCode")).to be_truthy

    expect(repair_request.errors.added?("description", "Please provide a valid Problem")).to be_truthy
  end
end

describe Hackney::RepairRequest do
  describe "#high_priority?" do
    it "works" do
      expect(Hackney::RepairRequest.new(priority: "E").high_priority?).to be_truthy
      expect(Hackney::RepairRequest.new(priority: "I").high_priority?).to be_truthy
      expect(Hackney::RepairRequest.new(priority: "K").high_priority?).to be_falsey
      expect(Hackney::RepairRequest.new(priority: "O").high_priority?).to be_falsey
      expect(Hackney::RepairRequest.new(priority: "U").high_priority?).to be_falsey
      expect(Hackney::RepairRequest.new(priority: "V").high_priority?).to be_falsey
      expect(Hackney::RepairRequest.new(priority: "N").high_priority?).to be_falsey
      expect(Hackney::RepairRequest.new(priority: "L").high_priority?).to be_falsey
    end
  end
end
