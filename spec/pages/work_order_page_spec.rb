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

    expect(page.contact).to be_a(Hackney::Contact)
    expect(page.contact.name).to eq('MR SULEYMAN ERBAS')

    expect(page.property).to be_a(Hackney::Property)
    expect(page.property.reference).to eq('00014665')
  end

  it 'raises a RecordNotFoundError error when a work order cannot be found' do
    stub_hackney_repairs_work_orders(status: 404)

    expect {
      described_class.new('01551932')
    }.to raise_error HackneyRepairsClient::RecordNotFoundError
  end

  it 'raises an error when the API fails to retrieve a work order' do
    stub_hackney_repairs_work_orders(status: 500)

    expect {
      described_class.new('01551932')
    }.to raise_error HackneyRepairsClient::ApiError
  end

  it 'raises an error when additional API calls fail' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests(status: 500)

    expect {
      described_class.new('01551932')
    }.to raise_error HackneyRepairsClient::ApiError
  end
end
