require 'rails_helper'

RSpec.describe 'Repair request' do
  include Helpers::Authentication
  include Helpers::HackneyRepairsRequestStubs

  def stub_post_repair_request
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
  end

  def stub_property
    stub_request(:get, "https://hackneyrepairs/v1/properties/00000018").to_return(
      status: 200,
      body: {
        "address" => "2 Acacia House  Lordship Road",
        "postcode" => "N16 0PX",
        "propertyReference" => "00000018",
        "maintainable" => true,
        "levelCode" => 7,
        "description" => "Dwelling",
        "tenure" => "Secure"
      }.to_json
    )
  end

  def stub_work_order
    stub_request(:get, "https://hackneyrepairs/v1/work_orders/01552718").to_return(
      status: 200,
      body: {
        "workOrderReference" => "01552718",
        "sorCode" => "08500820",
        "supplierReference" => "H01",
        "propertyReference" => "00000018",
        "created" => "2018-05-29T14:10:06",
        "dateDue" => "2018-06-27T14:09:00",
      }.to_json
    )
  end

  scenario 'Raise a repair' do
    stub_post_repair_request
    stub_property
    sign_in
    visit property_path('00000018', show_raise_a_repair: true)

    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties

    click_on 'Raise a repair on this property'

    fill_in "Problem description", with: "it's broken fix it"
    fill_in "Tenant name", with: "blablabla"
    fill_in "Contact number", with: "01234567890"
    fill_in "SOR Code", with: "08500820"
    select "G -", from: "Task priority"

    stub_work_order

    click_on 'Raise repair'

    expect(current_path).to be == work_order_path("01552718")
  end
end
