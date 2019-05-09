require 'rails_helper'

RSpec.describe 'Property' do
  include Helpers::Authentication

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

      ]
    }.to_json)

    #
    # hierarchy
    #
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties/00000666/hierarchy")
      .to_return(status: 200, body: [
        {
          "propertyReference": "00000666",
          "levelCode": "7",
          "description": "Dwelling",
          "majorReference": "00000665",
          "address": "1 Madeup Road",
          "postcode": "SW1A 1AA"
        },
        {
          "propertyReference": "00000665",
          "levelCode": "4",
          "description": "Sub-Block",
          "majorReference": "00000664",
          "address": "1-2 & 5-7 & 11-13 & 17-19 Madeup Road",
          "postcode": "SW1A 1AA"
        },
        {
          "propertyReference": "00000664",
          "levelCode": "3",
          "description": "Block",
          "majorReference": "00000663",
          "address": "1-21 Madeup Road",
          "postcode": "SW1A 1AA"
        },
        {
          "propertyReference": "00000663",
          "levelCode": "2",
          "description": "Estate",
          "majorReference": "00087086",
          "address": "Madeup Estate",
          "postcode": "SW1W 0DT"
        },
        {
          "propertyReference": "00087086",
          "levelCode": "0",
          "description": "Owner",
          "majorReference": "",
          "address": "Hackney Homes Limited  Wilton Way",
          "postcode": "E8 1BJ"
        }
    ].to_json)

    #
    # facilities
    #
    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/properties/00000666/facilities")
      .to_return(status: 200, body: {
      "results": [
        {
          "propertyReference": "00000663",
          "levelCode": "2",
          "description": "Estate",
          "majorReference": "00087086",
          "address": "Madeup Estate",
          "postcode": "SW1W 0DT"
        },
        {
          "propertyReference": "00000664",
          "levelCode": "3",
          "description": "Block",
          "majorReference": "00000663",
          "address": "1-21 Madeup Road",
          "postcode": "SW1A 1AA"
        },
        {
          "propertyReference": "00000665",
          "levelCode": "4",
          "description": "Sub-Block",
          "majorReference": "00000664",
          "address": "1-2 & 5-7 & 11-13 & 17-19 Madeup Road",
          "postcode": "SW1A 1AA"
        },
        {
          "propertyReference": "00000667",
          "levelCode": "6",
          "description": "Facilities",
          "majorReference": "00000665",
          "address": "Lift 666 1-2 & 5-7 & 11-13 & 17-19 Madeup Road",
          "postcode": "SW1A 1AA"
        },
        {
          "propertyReference": "00000668",
          "levelCode": "6",
          "description": "Facilities",
          "majorReference": "00000663",
          "address": "Community Hall & Tmo Office 14 Madeup Road",
          "postcode": "SW1W 0DT"
        }
      ]
    }.to_json)

    #
    # work orders
    #

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders?propertyReference=00000666&propertyReference=00000667&propertyReference=00000664&propertyReference=00000663&propertyReference=00000668&propertyReference=00000665&since=#{2.years.ago.strftime("%d-%m-%Y")}&until=#{1.day.from_now.strftime("%d-%m-%Y")}")
      .to_return(status: 200, body: [
        {
          "sorCode": "06550090",
          "trade": "Plumbing",
          "workOrderReference": "00000001",
          "repairRequestReference": "10000001",
          "problemDescription": "Problem 1",
          "created": "2017-05-30T15:40:17",
          "authDate": "1900-01-01T00:00:00",
          "estimatedCost": 297.74,
          "actualCost": 0.0,
          "completedOn": "1900-01-01T00:00:00",
          "dateDue": "2017-06-28T15:40:00",
          "workOrderStatus": "200",
          "dloStatus": "1",
          "servitorReference": "10139116",
          "propertyReference": "00000666"
        },
        {
          "sorCode": "06550080",
          "trade": "Plumbing",
          "workOrderReference": "00000002",
          "repairRequestReference": "10000002",
          "problemDescription": "Problem 2",
          "created": "2017-05-30T15:50:40",
          "authDate": "2017-05-30T15:51:00",
          "estimatedCost": 43.41,
          "actualCost": 0.0,
          "completedOn": "1900-01-01T00:00:00",
          "dateDue": "2017-06-28T15:50:00",
          "workOrderStatus": "200",
          "dloStatus": "",
          "servitorReference": "",
          "propertyReference": "00000666"
        },
        {
          "sorCode": "08500820",
          "trade": "Painting & Decorating",
          "workOrderReference": "00000003",
          "repairRequestReference": "10000003",
          "problemDescription": "Problem 3",
          "created": "2019-04-11T18:28:02",
          "authDate": "2019-04-11T18:28:00",
          "estimatedCost": 26.38,
          "actualCost": 0.0,
          "completedOn": "1900-01-01T00:00:00",
          "dateDue": "2019-05-10T18:28:00",
          "workOrderStatus": "100",
          "dloStatus": "",
          "servitorReference": "",
          "propertyReference": "00000666"
        }
    ].to_json)
  end

  scenario 'Shows related properties', :js do
    stub_property_00000666

    sign_in
    visit property_path('00000666')
    expect(page).to have_content('1 Madeup Road')

    click_on 'Related properties'
    within '#related-properties-tab' do
      expect(page).to have_link("Madeup Estate",                                    href: property_path("00000663"))
      expect(page).to have_link("1-21 Madeup Road",                                 href: property_path("00000664"))
      expect(page).to have_link("1-2 & 5-7 & 11-13 & 17-19 Madeup Road",            href: property_path("00000665"))
      expect(page).to have_link("Lift 666 1-2 & 5-7 & 11-13 & 17-19 Madeup Road",   href: property_path("00000667"))
      expect(page).to have_link("Community Hall & Tmo Office 14 Madeup Road",       href: property_path("00000668"))
    end
  end
end
