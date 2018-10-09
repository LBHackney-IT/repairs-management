require 'rails_helper'

describe Hackney::Report, '#build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'returns an array of work order reports from the API response' do
    model = described_class.build(work_order_reports_response_payload)

    expect(model).to be_a(Hackney::Report)
    expect(model.mobile_reports).to eq(work_order_reports_response_payload["mobileReports"])
  end

  it 'returns an empty array from the API response when there are no reports for a work order' do
    model = described_class.build(work_order_reports_response_payload__no_reports)

    expect(model).to be_a(Hackney::Report)
    expect(model.mobile_reports).to eq(work_order_reports_response_payload__no_reports["mobileReports"])
  end
end
