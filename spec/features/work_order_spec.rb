require 'rails_helper'

RSpec.describe 'Work order' do
  include Helpers::Authentication
  include Helpers::HackneyRepairsRequestStubs

  before { sign_in }

  scenario 'search for a work order by reference' do
    fill_in 'Work order reference', with: ''
    click_on 'Search'

    expect(page).to have_content 'Please provide a reference'

    stub_hackney_repairs_work_orders(reference: '00000000', status: 404)

    fill_in 'Work order reference', with: '00000000'
    click_on 'Search'

    expect(page).to have_content 'Could not find a work order with reference 00000000'

    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_appointment

    fill_in 'Work order reference', with: '01551932'
    click_on 'Search'

    expect(page).to have_content 'Work order 01551932'
    expect(page).to have_content 'TEST problem'

    expect(page).to have_content '12 Banister House Homerton High Street E9 6BH'
    expect(page).to have_content 'MR SULEYMAN ERBAS reported on 2:10pm, 29 May 2018'

    expect(page).to have_content 'Telephone number: 02012341234'
    expect(page).to have_content 'Email address: s.erbas@example.com'

    expect(page).to have_content 'Appointment Booked from 2:56pm, 10 June 2018'
    expect(page).to have_content 'Target date: 2:10pm, 11 June 2018'
    expect(page).to have_content 'Resource name: (PLM) Brian Liverpool'
    expect(page).to have_content 'Status: PLANNED'
    expect(page).to have_content 'Priority: N'
    expect(page).to have_content 'Data source: DRS'
  end
end
