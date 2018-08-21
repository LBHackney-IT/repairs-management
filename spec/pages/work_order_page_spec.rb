require 'rails_helper'

describe WorkOrderPage, '#new' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds the required models for a given work order reference' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments

    page = described_class.new('01551932')

    expect(page.work_order).to be_a(Hackney::WorkOrder)
    expect(page.work_order.reference).to eq('01551932')

    expect(page.repair_request).to be_a(Hackney::RepairRequest)
    expect(page.repair_request.reference).to eq('03209397')

    expect(page.contact).to be_a(Hackney::Contact)
    expect(page.contact.name).to eq('MR SULEYMAN ERBAS')

    expect(page.property).to be_a(Hackney::Property)
    expect(page.property.reference).to eq('00014665')

    expect(page.notes).to all(be_a(Hackney::Note))

    expect(page.latest_appointment).to be_a(Hackney::Appointment)
  end

  it 'raises a RecordNotFoundError error when a work order cannot be found' do
    stub_hackney_repairs_work_orders(status: 404)

    expect {
      described_class.new('01551932')
    }.to raise_error HackneyAPI::RepairsClient::RecordNotFoundError
  end

  it 'raises an error when the API fails to retrieve a work order' do
    stub_hackney_repairs_work_orders(status: 500)

    expect {
      described_class.new('01551932')
    }.to raise_error HackneyAPI::RepairsClient::ApiError
  end

  it 'raises an error when additional API calls fail' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests(status: 500)

    expect {
      described_class.new('01551932')
    }.to raise_error HackneyAPI::RepairsClient::ApiError
  end
end
