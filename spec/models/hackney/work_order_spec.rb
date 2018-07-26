require 'rails_helper'

describe Hackney::WorkOrder, '#build' do
  include Helpers::HackneyRepairsRequests

  it 'builds a work order for a given work order reference' do
    stub_hackney_repairs_work_orders

    model = described_class.new('01572924').build
    expect(model.reference).to eq('01572924')
  end

  it 'raises a not found error when the resource is not found' do
    stub_hackney_repairs_work_orders(reference: '00000000', status: 404)

    expect {
      described_class.new('00000000').build
    }.to raise_error Hackney::WorkOrder::RecordNotFound
  end

  it 'raises a generic error when the api returns a server error' do
    stub_hackney_repairs_work_orders(reference: '12345678', status: 500)

    expect {
      described_class.new('12345678').build
    }.to raise_error Hackney::WorkOrder::Error
  end
end
