require 'rails_helper'

RSpec.describe 'Work order' do
  include Helpers::HackneyRepairsRequests

  scenario 'search for a work order by reference' do
    stub_hackney_repairs_work_orders(reference: '00000000', status: 404)

    visit '/'
    click_on 'Sign in with Microsoft'
    fill_in 'Work order reference', with: '00000000'
    click_on 'Search'

    expect(page).to have_content 'Could not find a work order with reference 00000000'

    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties

    fill_in 'Work order reference', with: '01572924'
    click_on 'Search'

    expect(page).to have_content 'Ref: 01572924'
    expect(page).to have_content 'Description: Renew sealant around bath and splashback tiles'
    expect(page).to have_content 'Property: 45 Penn Road N7 1AA'
  end
end
