require 'rails_helper'

RSpec.describe 'Work order' do
  include Helpers::HackneyRepairsRequestStubs

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

    fill_in 'Work order reference', with: '01551932'
    click_on 'Search'

    expect(page).to have_content 'Work order 01551932'
    expect(page).to have_content 'TEST problem'
    expect(page).to have_content 'Reported on 2:10pm, 29 May 2018'
    expect(page).to have_content 'Property 12 Banister House Homerton High Street E9 6BH'
    expect(page).to have_content 'Tenant MR SULEYMAN ERBAS'
    expect(page).to have_content 'Telephone number: 02012341234'
    expect(page).to have_content 'Email address: s.erbas@example.com'
  end
end
