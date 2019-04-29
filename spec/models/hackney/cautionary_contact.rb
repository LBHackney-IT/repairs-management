require 'rails_helper'

describe Hackney::CautionaryContact, '.build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds when the API response contains all fields' do
    model = described_class.build(cautionary_contact_response_body['contact'])

    expect(model).to be_a(Hackney::CautionaryContact)
    expect(model.alert_code).to eq('CC')
  end

  it 'builds when the API response has minimal fields' do
    model = described_class.build({ 'alertCode' => 'SA' })

    expect(model.alert_code).to eq('SA')
    expect(model.caller_notes).to be_blank
  end

  it 'builds when the API response is empty' do
    model = described_class.build({})
    expect(model.name).to be_blank
  end
end
