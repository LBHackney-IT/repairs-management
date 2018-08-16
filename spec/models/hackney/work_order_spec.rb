require 'pry'
require 'rails_helper'

describe Hackney::WorkOrder, '#build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds a work order from the API response' do
    model = described_class.build(work_order_response_payload)

    expect(model.reference).to eq('01551932')
    expect(model.rq_ref).to eq('03209397')
    expect(model.prop_ref).to eq('00014665')
    expect(model.created).to eq DateTime.new(2018,05,29,14,10,06)
  end

  it "errors when given an invalid date to parse" do
    attributes = work_order_response_payload.merge('created' => 'null')

    expect {
      described_class.build(attributes)
    }.to raise_error.with_message('invalid date')
  end
end
