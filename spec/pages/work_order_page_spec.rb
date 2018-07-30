require 'rails_helper'

describe WorkOrderPage, '#new' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds the required models for a given work order reference' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties

    page = described_class.new('01551932')

    expect(page.work_order).to be_a(Hackney::WorkOrder)
    expect(page.work_order.reference).to eq('01551932')
    expect(page.repair_request).to be_a(Hackney::RepairRequest)
    expect(page.repair_request.reference).to eq('03209397')
    expect(page.property).to be_a(Hackney::Property)
    expect(page.property.reference).to eq('00014665')
  end
end
