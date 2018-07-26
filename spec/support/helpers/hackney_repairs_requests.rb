module Helpers
  module HackneyRepairsRequests
    def stub_hackney_repairs_work_orders(opts = {})
      reference = opts.fetch(:reference, '01572924')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, {
        "wo_ref" => "01572924",
        "prop_ref" => "00003182",
        "rq_ref" => "03249135",
        "created" => "2018-07-26T10:42:12Z"
      })

      stub_request(:get, "https://hackneyrepairs/v1/workorders/#{reference}")
      .to_return(status: status, body: body.to_json)
    end

    def stub_hackney_repairs_repair_requests(opts = {})
      reference = opts.fetch(:reference, '03249135')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, {
        "repairRequestReference" => "03249135",
        "propertyReference" => "00003182",
        "problemDescription" => "Renew sealant around bath and splashback tiles",
        "priority" => "N",
        "contact" => {
          "name" => "Joe Bloggs",
          "telephoneNumber" => "02012341234",
          "emailAddress" => "joe@blogs.com",
          "callbackTime" => "8am - 12pm"
        },
        "workOrders" => [
          {
            "workOrderReference" => "01572924",
            "sorCode" =>  "20090190",
            "supplierReference" => "00000127"
          }
        ]
      })

      stub_request(:get, "https://hackneyrepairs/v1/repairs/#{reference}")
        .to_return(status: status, body: body.to_json)
    end

    def stub_hackney_repairs_properties(opts = {})
      reference = opts.fetch(:reference, '00003182')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, {
        "propertyReference": "00003182",
        "postcode": "N7 1AA",
        "address": "45 Penn Road",
        "maintainable": true
      })

      stub_request(:get, "https://hackneyrepairs/v1/properties/#{reference}")
        .to_return(status: status, body: body.to_json)
    end
  end
end
