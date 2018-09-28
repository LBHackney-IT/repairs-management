module Helpers
  module HackneyRepairsRequestStubs
    # GET /v1/work_orders/:reference

    def work_order_response_payload(overrides = {})
      {
        "sorCode" => "08500110",
        "trade" => "Painting & Decorating",
        "workOrderReference" => "01551932",
        "repairRequestReference" => "03209397",
        "problemDescription" => "TEST problem",
        "created" => "2018-05-29T14:10:06",
        "estimatedCost" => 4.13,
        "actualCost" => 0.0,
        "completedOn" => "1900-01-01T00:00:00",
        "dateDue" => "2018-06-27T14:09:00",
        "workOrderStatus" => "200",
        "dloStatus" => "1",
        "servitorReference" => "10162765",
        "propertyReference" => "00014665"
      }.merge(overrides)
    end

    def stub_hackney_repairs_work_orders(opts = {})
      reference = opts.fetch(:reference, '01551932')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, work_order_response_payload)

      Graph::WorkOrder.find_or_create(reference: reference)

      stub_request(:get, "https://hackneyrepairs/v1/work_orders/#{reference}")
        .to_return(status: status, body: body.to_json)
    end

    # GET /v1/repairs/:reference

    def repair_request_response_payload(overrides = {})
      {
        "repairRequestReference" => "03209397",
        "problemDescription" => "TEST problem",
        "priority" => "N",
        "propertyReference" => "00014665",
        "contact" => {
          "name" => "MR SULEYMAN ERBAS",
          "telephoneNumber" => "02012341234",
          "emailAddress" => "s.erbas@example.com"
        },
        "workOrders" => [
          {
            "workOrderReference" => "01551932",
            "sorCode" => "08500110",
            "supplierReference" => "H09"
          }
        ]
      }.deep_merge(overrides)
    end

    def repair_request_response_payload__info_missing
      {
        "repairRequestReference" => "03209397",
        "problemDescription" => "Repair info missing"
      }
    end

    def stub_hackney_repairs_repair_requests(opts = {})
      reference = opts.fetch(:reference, '03209397')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, repair_request_response_payload)

      stub_request(:get, "https://hackneyrepairs/v1/repairs/#{reference}")
        .to_return(status: status, body: body.to_json)
    end

    # GET /v1/properties/:reference

    def property_response_payload
      {
        "address" => "Homerton High Street 12 Banister House",
        "postcode" => "E9 6BH",
        "propertyReference" => "00014665",
        "maintainable" => true
      }
    end

    def stub_hackney_repairs_properties(opts = {})
      reference = opts.fetch(:reference, '00014665')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, property_response_payload)

      stub_request(:get, "https://hackneyrepairs/v1/properties/#{reference}")
        .to_return(status: status, body: body.to_json)
    end

    # GET v1/workorders/:reference/notes

    def work_order_notes_payload
      [
        {
          "text": "Tenant called to confirm appointment",
          "loggedAt": "2018-08-23T10:12:56+01:00",
          "loggedBy": "MOSHEA"
        },
        {
          "text": "Further works required; Tiler required to renew splash back and reseal bath",
          "loggedAt": "2018-09-02T11:32:14+01:00",
          "loggedBy": "Servitor"
        }
      ]
    end

    def work_order_note_response_payload__no_notes
      []
    end

    def stub_hackney_repairs_work_order_notes(opts = {})
      reference = opts.fetch(:reference, '01551932')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, work_order_notes_payload)

      stub_request(:get, "https://hackneyrepairs/v1/work_orders/#{reference}/notes")
        .to_return(status: status, body: body.to_json)
    end

    # GET /v1/work_orders/:workOrderReference/appointments

    def work_order_appointments_response_payload
      [
        {
          "id" => "01551932",
          "status" => "planned",
          "assignedWorker" => "(PLM) Brian Liverpool",
          "phonenumber" => "+447535847993",
          "priority" => "standard",
          "sourceSystem" => "DRS",
          "comment" => nil,
          "creationDate" => "2018-05-29T14:51:36",
          "beginDate" => "2018-05-29T14:51:22",
          "endDate" => "2018-06-05T14:51:22"
        },
        {
          "id" => "01551932",
          "status" => "planned",
          "assignedWorker" => "(PLM) Fatima Bagam TEST",
          "phonenumber" => nil,
          "priority" => "standard",
          "sourceSystem" => "DRS",
          "comment" => "first",
          "creationDate" => "2018-05-29T14:10:49",
          "beginDate" => "2018-05-30T08:00:00",
          "endDate" => "2018-05-30T12:00:00"
        },
        {
          "id" => "01551932",
          "status" => "completed",
          "assignedWorker" => "(PLM) Fatima Bagam TEST",
          "phonenumber" => nil,
          "priority" => "standard",
          "sourceSystem" => "DRS",
          "comment" => "FIRST",
          "creationDate" => "2017-10-17T09:27:19",
          "beginDate" => "2017-10-17T09:27:00",
          "endDate" => "2017-10-24T09:27:00"
        }
      ]
    end

    def work_order_appointment_response_payload__out_of_target
      [
        {
          "id" => "01551932",
          "status" => "completed",
          "assignedWorker" => "(PLM) Fatima Bagam TEST",
          "phonenumber" => nil,
          "priority" => "standard",
          "sourceSystem" => "DRS",
          "comment" => "FIRST",
          "creationDate" => "2017-10-17T09:27:19",
          "beginDate" => "2018-06-28T08:00:00",
          "endDate" => "2018-06-28T12:00:00"
        }
      ]
    end

    def work_order_appointments_response_payload__no_creation_date
      [
        {
          "id" => "01551932",
          "status" => "planned",
          "assignedWorker" => "(PLM) Brian Liverpool",
          "phonenumber" => "+447535847993",
          "priority" => "standard",
          "sourceSystem" => "DRS",
          "comment" => nil,
          "beginDate" => "2018-05-29T14:51:22",
          "endDate" => "2018-06-05T14:51:22"
        }
      ]
    end

    def work_order_appointment_response_payload__no_appointments
      []
    end

    def stub_hackney_repairs_work_order_appointments(opts = {})
      reference = opts.fetch(:reference, '01551932')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, work_order_appointments_response_payload)

      stub_request(:get, "https://hackneyrepairs/v1/work_orders/#{reference}/appointments")
        .to_return(status: status, body: body.to_json)
    end

    def stub_hackney_repairs_work_order_latest_appointments(opts = {})
      reference = opts.fetch(:reference, '01551932')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, {
        "id": "01551945",
        "status": "completed",
        "assignedWorker": "(PLM) Tom Sabin Unboxed",
        "phonenumber": "02012341234",
        "priority": "standard",
        "sourceSystem": "DRS",
        "comment": "FIRST",
        "creationDate": "2018-05-31T15:05:51",
        "beginDate": "2018-05-31T08:00:00",
        "endDate": "2018-05-31T16:15:00"
      })

      stub_request(:get, "https://hackneyrepairs/v1/work_orders/#{reference}/appointments/latest")
        .to_return(status: status, body: body.to_json)
    end

    # work_orders_by_property_reference

    def work_orders_by_property_reference_payload
      [{
        "sorCode" => "20060060",
        "trade" => "Plumbing",
        "workOrderReference" => "00545095",
        "repairRequestReference" => "02054981",
        "problemDescription" => "rem - leak affecting 2 props below.",
        "created" => "2010-12-20T09:53:27",
        "estimatedCost" => 115.02,
        "actualCost" => 0,
        "completedOn" => "1900-01-01T00:00:00",
        "dateDue" => "2011-01-18T09:53:00",
        "workOrderStatus" => "300",
        "dloStatus" => "3",
        "servitorReference" => "00746221",
        "propertyReference" => "00014665"
      },
      {
        "sorCode" => "20060020",
        "trade" => "Plumbing",
        "workOrderReference" => "00547607",
        "repairRequestReference" => "02057576",
        "problemDescription" => "rem - leak in wc",
        "created" => "2010-12-23T09:58:58",
        "estimatedCost" => 57.51,
        "actualCost" => 0,
        "completedOn" => "1900-01-01T00:00:00",
        "dateDue" => "2011-01-21T09:59:00",
        "workOrderStatus" => "700",
        "dloStatus" => "1",
        "servitorReference" => "00767633",
        "propertyReference" => "00014665"
      },
      {
        "sorCode" => "4896802H",
        "trade" => "Domestic gas: servicing",
        "workOrderReference" => "00636321",
        "repairRequestReference" => "02148747",
        "problemDescription" => "Annual Gas Service",
        "created" => "2011-06-22T05:07:48",
        "estimatedCost" => 142.93,
        "actualCost" => 0,
        "completedOn" => "1900-01-01T00:00:00",
        "dateDue" => "2011-09-14T05:08:00",
        "workOrderStatus" => "300",
        "dloStatus" => "3",
        "servitorReference" => "01602146",
        "propertyReference" => "00014665"
      },
      {
        "sorCode" => "20110240",
        "trade" => "Electrical",
        "workOrderReference" => "01132479",
        "repairRequestReference" => "02670880",
        "problemDescription" => "ELEC pls rem deff light in living room tnt reports the light cord is very short but tnt reports that his lights blew out after 1 week of changing light bulb pls check connection and report back all f/o that may be required",
        "created" => "2014-04-01T10:23:09",
        "estimatedCost" => 107.51,
        "actualCost" => 0,
        "completedOn" => "1900-01-01T00:00:00",
        "dateDue" => "2014-04-30T10:23:00",
        "workOrderStatus" => "300",
        "dloStatus" => "3",
        "servitorReference" => "06218252",
        "propertyReference" => "00014665"
      }]
    end

    def stub_hackney_work_orders_for_property(reference: '00014665', status: 200,
                                              body: work_orders_by_property_reference_payload)
      stub_request(:get, "https://hackneyrepairs/v1/work_orders?propertyReference=#{reference}")
        .to_return(status: status, body: body.to_json)
    end

    def property_hierarchy_response_body
      [
        {
          propertyReference: '00014665',
          levelCode: '3',
          description: 'Block',
          majorReference: '00078632',
          address: '37-45 ODD Shrubland Road',
          postCode: 'E8 4NL'
        },
        {
          propertyReference: '00078632',
          levelCode: '2',
          description: 'Estate',
          majorReference: '00087086',
          address: 'Shrubland Estate  Shrubland Road',
          postCode: 'E8 4NL'
        }
      ]
    end

    def stub_hackney_property_hierarchy(opts = {})
      reference = opts.fetch(:reference, '00014665')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, property_hierarchy_response_body)

      stub_request(:get, "https://hackneyrepairs/v1/properties/#{reference}/hierarchy")
        .to_return(status: status, body: body.to_json)
    end

    # property_list_by_postcode_search

    def property_by_postcode_response_body(overrides = {})
      {
        "results": [
          {
            "address" => "Homerton High Street 10 Banister House",
            "postcode" => "E9 6BH",
            "propertyReference" => "00014663"
          },
          {
            "address" => "Homerton High Street 11 Banister House",
            "postcode" => "E9 6BH",
            "propertyReference" => "00014664"
          },
          {
            "address" => "Homerton High Street 12 Banister House",
            "postcode" => "E9 6BH",
            "propertyReference" => "00014665"
          },
          {
            "address" => "Homerton High Street 13 Banister House",
            "postcode" => "E9 6BH",
            "propertyReference" => "00014666"
          }
        ]
      }.merge(overrides)
    end

    def property_by_postcode_response_body__no_properties
      {
        "results": []
      }
    end

    def stub_hackney_property_by_postcode(reference: 'E96BH', status: 200,
                                          body: property_by_postcode_response_body)

      stub_request(:get, "https://hackneyrepairs/v1/properties?postcode=#{reference}")
        .to_return(status: status, body: body.to_json)
    end
  end
end
