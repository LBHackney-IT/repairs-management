module Helpers
  module HackneyRepairsRequestStubs

    API_VERSION = "v1"
    # GET /#{API_VERSION}/work_orders/:reference

    def work_order_response_payload(overrides = {})
      base = {
        "mobileReports" => nil,
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
        "propertyReference" => "00014665",
        "username" => "Celia"
      }

      unknown_keys = overrides.keys - base.keys
      raise "unknown key(s) : #{ unknown_keys }" if unknown_keys.any?

      base.merge(overrides)
    end

    def stub_hackney_repairs_work_orders(reference: '01551932', status: 200,
                                          body: work_order_response_payload)

      Graph::WorkOrder.find_or_create(reference: reference)

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/work_orders/#{reference}")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/repairs/:reference

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
            "supplierRef" => "H09"
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

    def stub_hackney_repairs_repair_requests(reference: '03209397', status: 200,
                                              body: repair_request_response_payload)

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/repairs/#{reference}")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/properties/:reference

    def property_response_payload(address: "Homerton High Street 12 Banister House",
                                  postcode: "E9 6BH",
                                  property_reference: "00014665",
                                  maintainable: true,
                                  level_code: 7,
                                  description: "Dwelling",
                                  letting_area: "Lordship South TMO (SN) H2556",
                                  tenure: "Secure")
      {
        "address" => address,
        "postcode" => postcode,
        "propertyReference" => property_reference,
        "maintainable" => maintainable,
        "levelCode" => level_code,
        "description" => description,
        "lettingArea" => letting_area,
        "tenure" => tenure
      }
    end

    def stub_hackney_repairs_properties(reference: '00014665', status: 200,
                                        body: property_response_payload)

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/properties/#{reference}")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/properties/by_references?reference=:reference

    def stub_hackney_repairs_properties_by_references(status: 200, references: [], body: [])
      params = references.map{ |ref| "reference=" + ref}.join('&')
      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/properties/by_references?#{params}")
        .to_return(status: status, body: body.to_json)
    end

    # GET #{API_VERSION}/repairs/:reference/block/work_orders?trade=:trade

    def repairs_work_order_block_by_trade_response(
          trade:,
          reference:,
          work_order_reference: '01106923',
          created: '2014-02-10T11:01:53',
          problem_description: 'PLM RECALL 01097105 FRED DICKENS: Tenant reports that kithcen sink is draining slowly again. REport back where blockag might be.'
        )
      [
        {
          'sorCode' => '21000006',
          'trade' => trade,
          'workOrderReference' => work_order_reference,
          'repairRequestReference' => '02643677',
          'problemDescription' => problem_description,
          'created' => created,
          'authDate' => '0001-01-01T00:00:00',
          'estimatedCost' => 55.65,
          'actualCost' => 0,
          'completedOn' => '1900-01-01T00:00:00',
          'dateDue' => '2014-03-11T11:02:00',
          'workOrderStatus' => '300',
          'dloStatus' => '3',
          'servitorReference' => '06006905',
          'propertyReference' => reference
        }
      ]
    end

    def stub_hackney_repairs_work_orders_by_reference(status: 200, references: [], body: [])
      params = references.map{ |ref| "reference=" + ref}.join('&')
      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/work_orders/by_references?#{params}")
        .to_return(status: status, body: body.to_json)
    end

    def stub_hackney_repairs_work_order_block_by_trade(
          reference: '00014665',
          status: 200,
          trade: 'Plumbing',
          date_from: '17-04-2018',
          date_to: '05-06-2018',
          body: repairs_work_order_block_by_trade_response(trade: trade, reference: reference)
          )

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/properties/#{reference}/block/work_orders?trade=#{trade}&since=#{date_from}&until=#{date_to}")
        .to_return(status: status, body: body.to_json)
    end

    # GET #{API_VERSION}/workorders/:reference/notes

    def work_order_notes_payload
      [
        {
          "text": "Tenant called to confirm appointment",
          "loggedAt": "2018-08-23T10:12:56+01:00",
          "loggedBy": "MOSHEA",
          "noteId": 3000
        },
        {
          "text": "Further works required; Tiler required to renew splash back and reseal bath",
          "loggedAt": "2018-09-02T11:32:14+01:00",
          "loggedBy": "Servitor",
          "noteId": 4000
        }
      ]
    end

    def work_order_note_response_payload__no_notes
      []
    end

    def stub_hackney_repairs_work_order_notes(reference: '01551932', status: 200,
                                              body: work_order_notes_payload)

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/work_orders/#{reference}/notes")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/work_orders/:reference/appointments

    def work_order_appointments_response_payload
      [
        {
          "id" => "01551932",
          "status" => "planned",
          "outcome" => nil,
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
          "outcome" => nil,
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
          "outcome" => "CO",
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
          "outcome" => "CO",
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
          "outcome" => nil,
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

    def stub_hackney_repairs_work_order_appointments(reference: '01551932', status: 200,
                                                      body: work_order_appointments_response_payload)

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/work_orders/#{reference}/appointments")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/work_orders/:reference/appointments/latest

    def stub_hackney_repairs_work_order_latest_appointments(opts = {})
      reference = opts.fetch(:reference, '01551932')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, {
        "id": "01551945",
        "status": "completed",
        "outcome": "CO",
        "assignedWorker": "(PLM) Tom Sabin Unboxed",
        "phonenumber": "02012341234",
        "priority": "standard",
        "sourceSystem": "DRS",
        "comment": "FIRST",
        "creationDate": "2018-05-31T15:05:51",
        "beginDate": "2018-05-31T08:00:00",
        "endDate": "2018-05-31T16:15:00"
      })

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/work_orders/#{reference}/appointments/latest")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/work_orders/:reference?include=mobilereports

    def work_order_reports_response_payload
      {
        "mobileReports" => [
          {
            "reportUri" => "\\\\LBHCAPCONINTP01\\portaldata\\HOUSING\\MobileRepairs\\Processed\\Works Order_11380283.pdf",
            "date" => "2017-07-17T21:10:59.9488026+00:00"
          },
          {
            "reportUri" => "\\\\LBHCAPCONINTP01\\portaldata\\HOUSING\\MobileRepairs\\Unprocessed\\Works Order_11380283 Copy (1).pdf",
            "date" => "2017-07-19T15:23:44.3750997+00:00"
          },
          {
            "reportUri" => "\\\\LBHCAPCONINTP01\\portaldata\\HOUSING\\MobileRepairs\\Unprocessed\\Works Order_11380283 Copy (2).pdf",
            "date" => "2017-07-20T15:27:34.2094981+00:00"
          }
        ]
      }
    end

    def work_order_reports_response_payload__no_reports
      {
        "mobileReports" => []
      }
    end

    def stub_hackney_repairs_work_order_reports(opts = {})
      reference = opts.fetch(:reference, '01551932')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, work_order_reports_response_payload)

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/work_orders/#{reference}?include=mobilereports")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/work_orders?propertyReference=:reference&since=#{date_from}&until=#{date_to}

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

    def work_orders_by_property_reference_payload__different_property
      [{
        "sorCode" => "20060060",
        "trade" => "Plumbing",
        "workOrderReference" => "00545095",
        "repairRequestReference" => "02054981",
        "problemDescription" => "THIS IS THE DIFF ONE",
        "created" => "2010-12-20T09:53:27",
        "estimatedCost" => 115.02,
        "actualCost" => 0,
        "completedOn" => "1900-01-01T00:00:00",
        "dateDue" => "2011-01-18T09:53:00",
        "workOrderStatus" => "300",
        "dloStatus" => "3",
        "servitorReference" => "00746221",
        "propertyReference" => "00024665"
      }]
    end

    def stub_hackney_work_orders_for_property(
          reference: '00014665',
          status: 200,
          years_ago: 2,
          date_to: Date.tomorrow.strftime("%d-%m-%Y"),
          body: work_orders_by_property_reference_payload
          )

      date_from = (Date.today - years_ago.years).strftime("%d-%m-%Y")

      reference = [reference] if reference.is_a? String
      references = reference.map{|r| "propertyReference=#{r}" }.join('&')

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/work_orders?#{references}&since=#{date_from}&until=#{date_to}")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/properties/:reference/hierarchy

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

    def property_hierarchy_response_body__estate
      [
        {
          propertyReference: '00024665',
          levelCode: '2',
          description: 'Estate',
          majorReference: '00087086',
          address: 'Shrubland Estate  Shrubland Road',
          postCode: 'E8 4NL'
        },
        {
          propertyReference: '00024665',
          levelCode: '0',
          description: 'Owner',
          majorReference: '00087086',
          address: 'The Owner Lives Here',
          postCode: 'E8 4NL'
        }
      ]
    end

    def stub_hackney_property_hierarchy(reference: '00014665', status: 200,
                                        body: property_hierarchy_response_body)

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/properties/#{reference}/hierarchy")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/properties?postcode=:reference

    def property_by_postcode_response_body(overrides = {})
      {
        "results": [
          {
            "address" => "Homerton High Street 10 Banister House",
            "postcode" => "E9 6BH",
            "propertyReference" => "00014663",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00074486"
          },
          {
            "address" => "Homerton High Street 11 Banister House",
            "postcode" => "E9 6BH",
            "propertyReference" => "00014664",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00074486"
          },
          {
            "address" => "Homerton High Street 12 Banister House",
            "postcode" => "E9 6BH",
            "propertyReference" => "00014665",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00074486"
          },
          {
            "address" => "Homerton High Street 13 Banister House",
            "postcode" => "E9 6BH",
            "propertyReference" => "00014666",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00074486"
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
                                          body: property_by_postcode_response_body,
                                          min_level: 8,
                                          max_level: 2)

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/properties?postcode=#{reference}&min_level=#{min_level}&max_level=#{max_level}")
        .to_return(status: status, body: body.to_json)
    end

    # GET /#{API_VERSION}/properties/fladdress?address=:reference

    def property_by_address_response_body(overrides = {})
      {
        "results": [
          {
            "propertyReference" => "00000017",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "1 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000018",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "2 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000019",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "3 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000020",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "4 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000021",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "5 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000022",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "6 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000023",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "7 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000024",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "8 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000025",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "9 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000026",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "10 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000027",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "11 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000028",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "12 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000029",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "13 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000030",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "14 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000031",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "15 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000032",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "16 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000033",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "17 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000034",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "18 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000035",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087477",
            "address" => "19 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000036",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "20 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000037",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "21 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00000038",
            "levelCode" => "7",
            "description" => "Dwelling",
            "majorReference" => "00087478",
            "address" => "22 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00050654",
            "levelCode" => "8",
            "description" => "Non-Dwell",
            "majorReference" => "00087086",
            "address" => "Psp 5 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00072649",
            "levelCode" => "6",
            "description" => "Facilities",
            "majorReference" => "00087478",
            "address" => "Lift 1449 3-4 & 8-10 & 14-16 & 20-22 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00072650",
            "levelCode" => "6",
            "description" => "Facilities",
            "majorReference" => "00087477",
            "address" => "Lift 1448 1-2 & 5-7 & 11-13 & 17-19 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00073953",
            "levelCode" => "3",
            "description" => "Block",
            "majorReference" => "00078393",
            "address" => "1-22 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00087477",
            "levelCode" => "4",
            "description" => "Sub-Block",
            "majorReference" => "00073953",
            "address" => "1-2 & 5-7 & 11-13 & 17-19 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          },
          {
            "propertyReference" => "00087478",
            "levelCode" => "4",
            "description" => "Sub-Block",
            "majorReference" => "00073953",
            "address" => "3-4 & 8-10 & 14-16 & 20-22 Acacia House  Lordship Road",
            "postcode" => "N16 0PX"
          }
        ]
      }.merge(overrides)
    end

    def property_by_address_response_body__no_properties
      {
        "results": []
      }
    end

    def stub_hackney_property_by_address(reference: 'Acacia', status: 200,
                                          body: property_by_address_response_body,
                                          limit:,
                                          min_level: 8,
                                          max_level: 2)
      params = {
        address: reference,
        limit: limit,
        min_level: min_level,
        max_level: max_level,
      }

      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/properties/fladdress")
        .with(query: params)
        .to_return(status: status, body: body.to_json)
    end

    def cautionary_contact_response_body
      {
        "contactAlerts": [
          {
            "alertCode": "VA",
            "alertDescription": "Verbal Abuse or Threat of"
          },
          {
            "alertCode": "CV",
            "alertDescription": "No Lone Visits"
          }
        ],
        "addressAlerts": [
          {
            "alertCode": "DIS",
            "alertDescription": "Property under Disrepair"
          }
        ],
        "callerNotes": [
          "Do not attend, bad singing"
        ]
      }
    end

    def stub_cautionary_contact_by_property_reference(reference: '00014665', status: 200,
                                                      body: cautionary_contact_response_body)
      stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/cautionary_contact/?reference=#{reference}")
        .to_return(status: status, body: body.to_json)
    end
  end
end
