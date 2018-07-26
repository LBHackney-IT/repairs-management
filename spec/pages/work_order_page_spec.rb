require 'rails_helper'

describe WorkOrderPage, '#new' do
  include Helpers::HackneyRepairsRequests

  it 'builds the required models for a given work order reference' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties

    page = described_class.new('01572924')

    expect(page.work_order).to be_a(Hackney::WorkOrder)
    expect(page.work_order.reference).to eq('01572924')
    expect(page.repair_request).to be_a(Hackney::RepairRequest)
    expect(page.repair_request.reference).to eq('03249135')
    expect(page.property).to be_a(Hackney::Property)
    expect(page.property.reference).to eq('00003182')
  end
end
