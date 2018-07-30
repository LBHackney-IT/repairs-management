require 'rails_helper'

describe Hackney::Contact, '.build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds when the API response contains all fields' do
    model = described_class.build(repair_request_response_payload['contact'])

    expect(model).to be_a(Hackney::Contact)
    expect(model.name).to eq('MR SULEYMAN ERBAS')
  end

  it 'builds when the API response has minimal fields' do
    model = described_class.build({ 'name' => 'Louis Litt' })

    expect(model.name).to eq('Louis Litt')
    expect(model.email_address).to be_blank
  end

  it 'builds when the API response is empty' do
    model = described_class.build({})
    expect(model.name).to be_blank
  end
end
