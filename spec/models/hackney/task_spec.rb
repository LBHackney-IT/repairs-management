require "rails_helper" 
describe Hackney::Task do
  describe ".for_work_order" do
    it "returns list of work order's tasks from API" do
      stub = stub_request(:get, "#{ ENV['HACKNEY_REPAIRS_API_BASE_URL'] }/v1/work_orders/00000666/tasks")
        .to_return(body: [{sorCode: "sorCode"}].to_json)

      expect(Hackney::Task).to receive(:new_from_api)
        .with({"sorCode" => "sorCode"})
        .and_call_original

      tasks = Hackney::Task.for_work_order("00000666")
      expect(stub).to have_been_requested
      expect(tasks.first.sor_code).to be == "sorCode"
      expect(tasks.count).to be == 1
    end
  end

  describe ".new_from_api" do
    it "creates task from API JSON" do
      task = Hackney::Task.new_from_api({
        "sorCode"                 => "66666666",
        "sorCodeDescription"      => "sorCodeDescription",
        "trade"                   => "trade",
        "workOrderReference"      => "00000666",
        "repairRequestReference"  => "00000333",
        "problemDescription"      => "problemDescription",
        "created"                 => "2006-06-06T06:06:06",
        "authDate"                => "2006-06-06T06:06:07",
        "estimatedCost"           => 6.66,
        "actualCost"              => 66.6,
        "completedOn"             => "2006-06-06T06:06:08",
        "dateDue"                 => "2006-06-06T06:06:09",
        "workOrderStatus"         => "200",
        "dloStatus"               => "1",
        "servitorReference"       => "00000999",
        "propertyReference"       => "00000111",
        "supplierRef"             => "H01",
        "userLogin"               => "PUDDING",
        "username"                => "Pudding",
        "authorisedBy"            => "AUTHORIZER",
        "EstimatedUnits"          => 666,
        "unitType"                => "Itm",
        "taskStatus"              => "200",
      })

      expect(task.sor_code).to be ==                  "66666666"
      expect(task.sor_code_description).to be ==      "sorCodeDescription"
      expect(task.trade).to be ==                     "trade"
      expect(task.work_order_reference).to be ==      "00000666"
      expect(task.repair_request_reference).to be ==  "00000333"
      expect(task.problem_description).to be ==       "problemDescription"
      expect(task.created_at).to be ==                DateTime.new(2006, 6, 6, 6, 6, 6)
      expect(task.auth_date).to be ==                 DateTime.new(2006, 6, 6, 6, 6, 7)
      expect(task.estimated_cost).to be ==            6.66
      expect(task.actual_cost).to be ==               66.6
      expect(task.completed_at).to be ==              DateTime.new(2006, 6, 6, 6, 6, 8)
      expect(task.date_due).to be ==                  DateTime.new(2006, 6, 6, 6, 6, 9)
      expect(task.work_order_status).to be ==         "200"
      expect(task.dlo_status).to be ==                "1"
      expect(task.servitor_reference).to be ==        "00000999"
      expect(task.property_reference).to be ==        "00000111"
      expect(task.supplier_reference).to be ==        "H01"
      expect(task.user_login).to be ==                "PUDDING"
      expect(task.user_name).to be ==                 "Pudding"
      expect(task.authorised_by).to be ==             "AUTHORIZER"
      expect(task.estimated_units).to be ==           666
      expect(task.unit_type).to be ==                 "Itm"
      expect(task.status).to be ==                    "200"
    end
  end

  describe "#is_dlo?" do
    it "returns whether task is DLO or not" do
      expect(Hackney::Task.new(supplier_reference: "H10").is_dlo?).to be_truthy
      expect(Hackney::Task.new(supplier_reference: "H01").is_dlo?).to be_truthy
      expect(Hackney::Task.new(supplier_reference: "H07").is_dlo?).to be_truthy
      expect(Hackney::Task.new(supplier_reference: "H05").is_dlo?).to be_truthy
      expect(Hackney::Task.new(supplier_reference: "H08").is_dlo?).to be_truthy
      expect(Hackney::Task.new(supplier_reference: "ENV").is_dlo?).to be_falsey
      expect(Hackney::Task.new(supplier_reference: "SCC").is_dlo?).to be_falsey
      expect(Hackney::Task.new(supplier_reference: "PCL").is_dlo?).to be_falsey
      expect(Hackney::Task.new(supplier_reference: "H12").is_dlo?).to be_truthy
      expect(Hackney::Task.new(supplier_reference: "AVP").is_dlo?).to be_falsey
      expect(Hackney::Task.new(supplier_reference: "ELA").is_dlo?).to be_falsey
      expect(Hackney::Task.new(supplier_reference: "EUC").is_dlo?).to be_falsey
      expect(Hackney::Task.new(supplier_reference: "STA").is_dlo?).to be_falsey
    end
  end
end
