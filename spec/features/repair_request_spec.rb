require 'rails_helper'

RSpec.describe 'Repair request' do
  include Helpers::Authentication
  # include Helpers::HackneyRepairsRequestStubs

  def stub_post_repair_request
    stub_request(:post, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/repairs").with(
      headers: {
        "Content-Type" => "application/json-patch+json"
      },
      body: {
        "contact": {
          "name": "Miss Piggy",
          "telephoneNumber": "01234567890",
        },
        "workOrders": [{
          "sorCode": "20110120",
        }],
        "priority": "E",
        "propertyReference": "00000666",
        "problemDescription": "It's broken",
        "lbhEmail": Helpers::Authentication::EMAIL
      }.to_json
    ).to_return(
      status: 200,
      body: {
        "repairRequestReference" => "03210303",
        "propertyReference" =>"00000666",
        "problemDescription" => "It's broken",
        "priority" => "E",
        "contact" => {
          "name" => "Miss Piggy",
          "telephoneNumber" => "01234567890"
        },
        "workOrders"=> [
          {
            "workOrderReference" => "01552718",
            "sorCode" => "20110120",
            "supplierReference" => "H01"
          }
        ]
      }.to_json
    )

    stub_request(:post, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/01552718/issue").with(
      headers: {
        "Content-Type" => "application/json-patch+json"
      },
      body: {
        "lbhEmail": Helpers::Authentication::EMAIL
      }.to_json
    ).to_return(
      status: 200,
      body: {}.to_json
    )
  end

  def stub_post_bad_repair_request
    stub_request(:post, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/repairs").with(
      headers: {
        "Content-Type" => "application/json-patch+json"
      },
      body: {
        "contact": {
          "name": "Miss Piggy",
          "telephoneNumber": "01234567890",
        },
        "workOrders": [{
          "sorCode": "Abcdefg",
        }],
        "priority": "E",
        "propertyReference": "00000666",
        "problemDescription": "It's broken",
        "lbhEmail": Helpers::Authentication::EMAIL
      }.to_json
    ).to_return(
      status: 500,
      body: {
      }.to_json
    )
  end

  def stub_keyfax_get_startup_url
    uri = URI(current_url)
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/keyfax/get_startup_url/?returnurl=#{new_property_repair_request_url('00000666', host: uri.host, port: uri.port)}")
    .to_return(
      status: 200,
      body:
      { "body":
        { "startupResult":
          { "launchUrl" => "https://www.keyfax.com",
            "guid" => "123456789"
          }
        }
      }.to_json
    )
  end

  def stub_keyfax_get_results_response
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/keyfax/kf_result/123456789")
      .to_return(status: 200,
        body:
        {
          "faultText" => "Electric lighting: Communal; Block Lighting; 3; All lights out",
          "repairCode" => "20110120",
          "repairCodeDesc" => "LANDLORDS LIGHTING-FAULT",
          "priority" => "E"
        }.to_json
      )
  end

  def stub_work_order
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/01552718").to_return(
      status: 200,
      body: {
        "workOrderReference" => "01552718",
        "sorCode" => "20110120",
        "supplierReference" => "H01",
        "propertyReference" => "00000666",
        "created" => "2018-05-29T14:10:06",
        "dateDue" => "2018-06-27T14:09:00",
      }.to_json
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/01552718/notes").to_return(
      status: 200,
      body: []
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/repairs/").to_return(
      status: 200,
      body: {
        "repairRequestReference" => "03210303",
        "propertyReference" =>"00000666",
        "problemDescription" => "It's broken",
        "priority" => "E",
        "contact" => {
          "name" => "Miss Piggy",
          "telephoneNumber" => "01234567890"
        },
        "workOrders"=> [
          {
            "workOrderReference" => "01552718",
            "sorCode" => "20110120",
            "supplierReference" => "H01"
          }
        ]
      }.to_json
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/01552718/appointments/latest").to_return(
      status: 200,
      body: [].to_json
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/01552718/appointments").to_return(
      status: 200,
      body: [].to_json
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties/00000666/block/work_orders?since=17-04-2018&trade=Plumbing&until=05-06-2018").to_return(
      status: 200,
      body: [].to_json
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/01552718?include=mobilereports").to_return(
      status: 200,
      body: { "mobileReports" => []}.to_json
    )
  end

  def stub_property_00000666
    #
    # property
    #
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties/00000666")
      .to_return(status: 200, body: {
      "address": "1 Madeup Road",
      "postcode": "SW1A 1AA",
      "propertyReference": "00000666",
      "maintainable": true,
      "levelCode": 7,
      "description": "Dwelling",
      "tenureCode": "SEC",
      "tenure": "Secure"
    }.to_json)
    #
    # cautionary contacts
    #
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/cautionary_contact/?reference=00000666")
      .to_return(status: 200, body: {
      "results": [
        { "alertCode" => "CC" }
      ]
    }.to_json)
    #
    # hierarchy
    #
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties/00000666/hierarchy")
      .to_return(status: 200, body: [].to_json)
    #
    # facilities
    #
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties/00000666/facilities")
      .to_return(status: 200, body: {
      "results": []}.to_json)
    #
    # work orders
    #
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders?since=#{2.years.ago.strftime("%d-%m-%Y")}&until=#{1.day.from_now.strftime("%d-%m-%Y")}")
      .to_return(status: 200, body: [].to_json)
    #
    # related facilities
    #
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties?max_level=6&min_level=6&postcode=SW1A%201AA")
      .to_return(status: 200, body: { "results":[]}.to_json)
  end

  def stub_property_temp_annex
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties/207044451").to_return(
      status: 200,
      body: {
        "address": "FLAT 6 36-38 BANK APARTMENTS",
        "postcode": "N11 1NA",
        "propertyReference": "207044451",
        "maintainable": true,
        "levelCode": 7,
        "description": "Dwelling",
        "tenureCode": "TLA",
        "tenure": "Temp Annex",
        "lettingArea" => "neighbourhood"
      }.to_json
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/cautionary_contact/?reference=207044451").to_return(
      status: 200,
      body: {
      "results": [
        { "alertCode" => "CC" }
        ]
      }.to_json
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties/207044451/hierarchy").to_return(
      status: 200,
      body: [].to_json
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties/207044451/facilities").to_return(
      status: 200,
      body: {
        "results": []
      }.to_json
    )

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders?since=#{2.years.ago.strftime("%d-%m-%Y")}&until=#{1.day.from_now.strftime("%d-%m-%Y")}")
      .to_return(status: 200, body: [].to_json)
  end

  context 'Secure tenure' do
    scenario 'Raise a repair successfully', :js do
      stub_property_00000666
      stub_post_repair_request

      sign_in
      visit property_path('00000666')

      stub_keyfax_get_startup_url

      expect(page).to have_css(".hackney-property-warning-label-turquoise")
      click_on 'Raise a repair on this dwelling'

      expect(page).to have_content "CC"
      expect(page).to have_link("Launch Keyfax", href: "https://www.keyfax.com")

      stub_keyfax_get_results_response

      visit new_property_repair_request_path('00000666', status: "1", guid: '123456789')

      fill_in "Problem description", with: "It's broken"
      fill_in "Caller name", with: "Miss Piggy"
      fill_in "Contact number", with: "01234567890"

      stub_work_order

      click_on 'Create works order'

      expect(current_path).to be == property_repair_requests_path("00000666")

      expect(page).to have_text("Repair work order created")
      expect(page).to have_text("Work order number\n01552718")
      expect(page).to have_link("open DRS", href: drs_url)
      expect(page).to have_link("Raise new repair on 1 Madeup Road", href: new_property_repair_request_path("00000666"))
      expect(page).to have_link("Back to 1 Madeup Road", href: property_path("00000666"))
      expect(page).to have_link("Start a new search", href: root_path)
    end

    scenario 'Raise a repair unsuccessfully', :js do
      stub_property_00000666
      stub_post_repair_request

      sign_in
      visit property_path('00000666')

      stub_keyfax_get_startup_url

      expect(page).to have_css(".hackney-property-warning-label-turquoise")
      click_on 'Raise a repair on this dwelling'

      expect(page).to have_content "CC"
      expect(page).to have_link("Launch Keyfax", href: "https://www.keyfax.com")

      stub_post_bad_repair_request

      fill_in "SOR Code", with: "Abcdefg"
      fill_in "Problem description", with: "It's broken"
      fill_in "Caller name", with: "Miss Piggy"
      fill_in "Contact number", with: "01234567890"

      click_on 'Create works order'

      expect(current_path).to be == property_repair_requests_path('00000666')
    end
  end

  context 'Leasehold RTB tenure' do
    scenario 'Cannot raise repair', :js do
      sign_in
      stub_property_temp_annex
      visit property_path('207044451')

      expect(page).to have_css(".hackney-property-warning-label-orange")
      expect(page).to have_text("Cannot raise a repair on this property due to tenure type")
    end
  end
end
