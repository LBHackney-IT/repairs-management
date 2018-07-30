module Helpers
  module HackneyRepairsRequestStubs
    # GET /v1/workorders/:reference

    def work_order_response_payload
      {
        "wo_ref" => "01551932  ",
        "sup_ref" => "H09         ",
        "prop_ref" => "00014665    ",
        "created" => "2018-05-29T14:10:06",
        "user_code" => "C8C",
        "issued" => "2018-05-29T14:11:01",
        "rep_type" => "240",
        "rep_class" => "001",
        "confirmation_order" => false,
        "wo_type" => "R",
        "plan_ref" => "               ",
        "est_cost" => 4.13,
        "fc" => false,
        "completed" => "1900-01-01T00:00:00",
        "rmworder_sid" => 152221260,
        "date_due" => "2018-06-27T14:09:00",
        "auth_by" => "C8C",
        "auth_date" => "2018-05-29T14:10:00",
        "authorised" => 1,
        "wo_version" => 1,
        "h_verbal_date" => "1900-01-01T00:00:00",
        "h_comments" => "",
        "expected_completion" => "2018-05-30T12:00:00",
        "cancelled_date" => "1900-01-01T00:00:00",
        "work_complete" => false,
        "wo_status" => "200",
        "ok_to_statement" => false,
        "statement_approver" => "   ",
        "statemented" => false,
        "statement_no" => "                    ",
        "statement_date" => "1900-01-01T00:00:00",
        "insp_outcome" => "   ",
        "post_insp" => false,
        "posti_sys" => " ",
        "rq_ref" => "03209397",
        "est_cost_ori" => 4.13,
        "datecomp" => "1900-01-01T00:00:00",
        "satisfied" => false,
        "courtious" => false,
        "appointkept" => false,
        "punctual" => false,
        "proced" => false,
        "advice" => false,
        "caller" => false,
        "satisfied_n" => false,
        "courtious_n" => false,
        "appointkept_n" => false,
        "punctual_n" => false,
        "proced_n" => false,
        "advice_n" => false,
        "caller_n" => false,
        "tensatcomments" => "",
        "tstamp" => "AAAAAQrP5Xg=",
        "hasfeedback" => false,
        "fbcardsentdate" => "1900-01-01T00:00:00",
        "fbcardsissued" => 0,
        "reason_late" => " ",
        "datecomp_user" => "1900-01-01T00:00:00",
        "change_reason" => "   ",
        "change_no" => 0,
        "statement_old" => "                    ",
        "statremove_dt" => "1900-01-01T00:00:00",
        "composite_sor" => "           ",
        "vm_propref" => "                ",
        "lettability" => false,
        "attend_date" => "1900-01-01T00:00:00",
        "u_interface_status" => " ",
        "u_interface_date" => "2018-05-29T14:30:20.78",
        "u_saffron_job_number" => "            ",
        "u_priority" => "   ",
        "u_dlo_status" => "1  ",
        "u_dlo_status_date" => "2018-05-29T14:11:01",
        "u_servitor_ref" => "10162765                                          ",
        "u_status_desc" => "Acknowlegement Received",
        "u_allocated_resource" => " ",
        "u_servitor_user" => " ",
        "act_cost" => 0
      }
    end

    def stub_hackney_repairs_work_orders(opts = {})
      reference = opts.fetch(:reference, '01551932')
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, work_order_response_payload)

      stub_request(:get, "https://hackneyrepairs/v1/workorders/#{reference}")
        .to_return(status: status, body: body.to_json)
    end

    # GET /v1/repairs/:reference

    def repair_request_response_payload
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
        "address" => "12 Banister House Homerton High Street",
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
  end
end
