require 'rails_helper'

describe Hackney::Property, '#build' do
  include Helpers::HackneyRepairsRequests

  it 'builds a work order for a given work order reference' do
    stub_hackney_repairs_properties

    model = described_class.new('00003182').build
    expect(model.reference).to eq('00003182')
  end

  it 'raises a not found error when the resource is not found' do
    stub_hackney_repairs_properties(reference: '00000000', status: 404)

    expect {
      described_class.new('00000000').build
    }.to raise_error Hackney::Property::RecordNotFound
  end

  it 'raises a generic error when the api returns a server error' do
    stub_hackney_repairs_properties(reference: '12345678', status: 500)

    expect {
      described_class.new('12345678').build
    }.to raise_error Hackney::Property::Error
  end
end
