require 'rails_helper'

describe Hackney::RepairRequest, '#build' do
  include Helpers::HackneyRepairsRequests

  it 'builds a repair request for the given repair request reference' do
    stub_hackney_repairs_repair_requests

    model = described_class.new('03249135').build
    expect(model.reference).to eq('03249135')
    expect(model.description).to eq('Renew sealant around bath and splashback tiles')
  end

  it 'raises a not found error when the resource is not found' do
    stub_hackney_repairs_repair_requests(reference: '00000000', status: 404)

    expect {
      described_class.new('00000000').build
    }.to raise_error Hackney::RepairRequest::RecordNotFound
  end

  it 'raises a generic error when the api returns a server error' do
    stub_hackney_repairs_repair_requests(reference: '12345678', status: 500)

    expect {
      described_class.new('12345678').build
    }.to raise_error Hackney::RepairRequest::Error
  end
end
