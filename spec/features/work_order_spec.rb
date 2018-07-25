require 'rails_helper'

RSpec.describe 'Work order' do
  scenario 'search for a work order by reference' do
    stub_request(:get, "https://hackneyrepairs/v1/workorders/00000000")
      .to_return(status: 404)

    visit '/'
    click_on 'Sign in with Microsoft'
    fill_in 'Work order reference', with: '00000000'
    click_on 'Search'

    expect(page).to have_content 'Could not find a work order with reference 00000000'

    api_response = {
      "wo_ref" => "01572924",
      "prop_ref" => "00003182",
      "rq_ref" => "03249135",
      "created" => "2018-07-26T10:42:12Z"
    }

    stub_request(:get, "https://hackneyrepairs/v1/workorders/01572924")
      .to_return(status: 200, body: api_response.to_json)

    fill_in 'Work order reference', with: '01572924'
    click_on 'Search'

    expect(page).to have_content 'Ref: 01572924'
  end
end
