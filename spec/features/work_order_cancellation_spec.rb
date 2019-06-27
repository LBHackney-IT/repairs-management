require 'rails_helper'

RSpec.describe 'Work Order Cancellation' do
  include Helpers::Authentication

  scenario 'Cancel a Work Order correctly', :js do
    sign_in

    # FIXME: s/hackneyrepairs/#{ ENV["..."] }/g

    #
    # stub minimum possible
    #
    stub_request(:get, "https://hackneyrepairs/v1/work_orders/00000666")
      .to_return(
        status: 200,
        body: {
          propertyReference: "00000333",
          workOrderReference: "00000666",
          repairRequestReference: "00000999",
          trade: "Plumbing",
          problemDescription: "It's broken",
          workOrderStatus: "200",
          created: "2006-06-06T06:06:06",
          dateDue: "2006-06-06T06:06:06",
        }.to_json
      )

    stub_request(:get, "https://hackneyrepairs/v1/properties/00000333")
      .to_return(
        status: 200,
        body: {
          propertyReference: "00000333",
          description: "Dwelling",
          address: "1 Madeup Road"
        }.to_json
      )

    stub_request(:get, "https://hackneyrepairs/v1/cautionary_contact/?reference=00000333")
      .to_return(
        status: 200,
        body: {
          results: {
          }
        }.to_json
      )

    stub_request(:get, "https://hackneyrepairs/v1/repairs/00000999")
      .to_return(
        status: 200,
        body: {
          repairRequestReference: "00000999",
          contact: {},
          workOrders: [],
        }.to_json
      )

    stub_request(:get, "https://hackneyrepairs/v1/work_orders/00000666/notes")
      .to_return(status: 200, body: "[]")

    stub_request(:get, "https://hackneyrepairs/v1/work_orders/00000666/appointments")
      .to_return(status: 200, body: "[]")

    stub_request(:get, "https://hackneyrepairs/v1/work_orders/00000666/appointments/latest")
      .to_return(status: 404)

    stub_request(:get, "https://hackneyrepairs/v1/properties/00000333/block/work_orders?since=25-04-2006&trade=Plumbing&until=13-06-2006")
      .to_return(status: 200, body: "[]")

    stub_request(:get, "https://hackneyrepairs/v1/properties/00000333/hierarchy")
      .to_return(status: 200, body: "[]")

    stub_request(:get, "https://hackneyrepairs/v1/properties/00000333/facilities")
      .to_return(
        status: 200,
        body: {
          results: []
        }.to_json
      )

    stub_request(:get, "https://hackneyrepairs/v1/work_orders/00000666?include=mobilereports")
      .to_return(
        status: 200,
        body: {
          mobileReports: []
        }.to_json
      )

    #
    # actually do something
    #
    visit work_order_path("00000666")
    expect(page).to have_content("Works order: 00000666")
    expect(page).to have_content("Status: In Progress")

    click_on "Cancel repair"

    expect(page).to have_content("Works order: 00000666")
    expect(page).to have_content("Property Dwelling, 1 Madeup Road")
    expect(page).to have_content("Trade Plumbing")
    expect(page).to have_content("Description It's broken")

    fill_in "Reason to cancel", with: "Reasonable Reason"

    #
    # stub the change of state
    #
    stub_request(:post, "https://hackneyrepairs/v1/work_orders/00000666/cancel")
      .with(
        body: {
          lbhEmail: Helpers::Authentication::EMAIL
        }.to_json, 
      ).to_return(status: 200, body: "{}")

    stub_request(:post, "https://hackneyrepairs/v1/notes")
      .with(
        body: {
          objectKey: "uhorder",
          objectReference: "00000666",
          text: "Reasonable Reason",
          lbhemail: Helpers::Authentication::EMAIL
        }.to_json
      ).to_return(status: 200, body: "{}")

    stub_request(:get, "https://hackneyrepairs/v1/work_orders/00000666")
      .to_return(
        status: 200,
        body: {
          propertyReference: "00000333",
          workOrderReference: "00000666",
          repairRequestReference: "00000999",
          trade: "Plumbing",
          problemDescription: "It's broken",
          workOrderStatus: "700",
          created: "2006-06-06T06:06:06",
          dateDue: "2006-06-06T06:06:06",
        }.to_json
      )

    stub_request(:get, "https://hackneyrepairs/v1/work_orders/00000666/notes")
      .to_return(
        status: 200,
        body: [
          {
            "workOrderReference": "00000666",
            "noteId": 6666666,
            "text": "Reasonable Reason",
            "loggedAt": "2006-06-06T06:06:06",
            "loggedBy": "Pudding"
          }
        ].to_json
      )

    click_on "Cancel repair"

    expect(current_path).to be == work_order_path("00000666")
    expect(page).to have_content("Status: Cancel Order")

    click_on "Notes and appointments"
    expect(page).to have_content("by Pudding")
    expect(page).to have_content("Reasonable Reason")
  end
end
