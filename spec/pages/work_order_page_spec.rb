require 'rails_helper'

describe WorkOrderPage, '#new' do
  it 'builds the required models for a given work order reference' do
    stub_request(:get, "https://hackneyrepairs/v1/workorders/01572924")
      .to_return(status: 200, body: {
        "wo_ref" => "01572924",
        "prop_ref" => "00003182",
        "rq_ref" => "03249135",
        "created" => "2018-07-26T10:42:12Z"
      }.to_json)

    page = described_class.new('01572924')
    expect(page.work_order).to be_a(Hackney::WorkOrder)
    expect(page.work_order.reference).to eq('01572924')
  end
end
