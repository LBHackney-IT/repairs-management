require 'rails_helper'

RSpec.describe RepairRequestsController, type: :controller do
  def fake_session
    session[:current_user] = {
      "name" => "Agent Piggy",
      "email" => "agent.piggy@hackney.gov.uk"
    }
  end

  def stub_property
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

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/cautionary_contact/?reference=00000666")
      .to_return(status: 200, body: {
      "results": {
        "alertCodes": [ "CC" ],
        "callerNotes": nil
      }
    }.to_json)

    stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/keyfax/get_startup_url/?returnurl=#{new_property_repair_request_url('00000666')}")
      .to_return(
        status: 200,
        body: {
          "body": {
            "startupResult": {
              "launchUrl": "https://www.keyfax.com",
              "guid": "123456789"
            }
          }
        }.to_json)
  end

  describe "POST" do

    context "with DLO task" do
      it "works" do
        fake_session
        stub_property

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
              "EstimatedUnits": ?1
            }],
            "priority": "E",
            "propertyReference": "00000666",
            "problemDescription": "It's broken",
            "isRecharge": true,
            "lbhEmail": "agent.piggy@hackney.gov.uk"
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
                "workOrderReference" => "00060606",
                "sorCode" => "20110120",
                "supplierRef" => "H01"
              }
            ]
          }.to_json
        )

        stub_request(:post, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/00060606/issue").with(
          headers: {
            "Content-Type" => "application/json-patch+json"
          },
          body: {
            "lbhEmail": "agent.piggy@hackney.gov.uk"
          }.to_json
        ).to_return(
          status: 200,
          body: {}.to_json
        )

        post :create, params: {
          property_ref: "00000666",
          hackney_repair_request: {
            contact_attributes: {
              name: "Miss Piggy",
              telephone_number: "01234567890",
            },
            tasks_attributes: [{
              "sor_code": "20110120",
              "estimated_units": 1
            }],
            "priority": "E",
            description: "It's broken",
            recharge: "1",
          }
        }

        expect(response).to be_successful
        expect(a_request(:post, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/repairs"))
          .to have_been_made
        expect(a_request(:post, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/00060606/issue"))
          .to have_been_made
      end
    end

    context "with non-DLO task" do
      it "works" do
        fake_session
        stub_property

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
              "sorCode": "LME5R500",
              "EstimatedUnits": ?1
            }],
            "priority": "E",
            "propertyReference": "00000666",
            "problemDescription": "It's broken",
            "isRecharge": true,
            "lbhEmail": "agent.piggy@hackney.gov.uk"
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
                "workOrderReference" => "00060606",
                "sorCode" => "LME5R500",
                "supplierRef" => "ELA"
              }
            ]
          }.to_json
        )

        post :create, params: {
          property_ref: "00000666",
          hackney_repair_request: {
            contact_attributes: {
              name: "Miss Piggy",
              telephone_number: "01234567890",
            },
            tasks_attributes: [{
              "sor_code": "LME5R500",
              "estimated_units": 1
            }],
            "priority": "E",
            description: "It's broken",
            "recharge": "1",
          }
        }

        expect(response).to be_successful
        expect(a_request(:post, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/repairs"))
          .to have_been_made
        expect(a_request(:post, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/00060606/issue"))
          .not_to have_been_made
      end
    end
  end
end
