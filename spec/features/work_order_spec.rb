require 'rails_helper'

RSpec.describe 'Work order' do
  include Helpers::Authentication
  include Helpers::HackneyRepairsRequestStubs

  before { sign_in }

  scenario 'Search for a work order by reference' do
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
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments

    fill_in 'Work order reference', with: '01551932'
    click_on 'Search'

    expect(page).to have_content 'Work order 01551932'
    expect(page).to have_content 'TEST problem'

    expect(page).to have_content '12 Banister House Homerton High Street E9 6BH'

    expect(page).to have_content 'MR SULEYMAN ERBAS reported on 2:10pm, 29 May 2018'
    expect(page).to have_content '02012341234'
    expect(page).to have_content 's.erbas@example.com'

    expect(page).to have_content 'Booked from 8:00am, 30 May 2018'
    expect(page).to have_content 'Priority: N'
    expect(page).to have_content 'Status: Acknowlegement Received'
    expect(page).to have_content 'Data source: UH'

    expect(page).to have_content 'Target date: 2:09pm, 27 June 2018'

    expect(page).to have_content 'Notes'
    within(find('h2', text: 'Notes').find('~ ul')) do
      expect(all('li').map(&:text)).to eq([
        "11:32am, 2 September 2018 by Servitor\nFurther works required; Tiler required to renew splash back and reseal bath",
        "10:12am, 23 August 2018 by MOSHEA\nTenant called to confirm appointment",
      ])
    end
  end

  scenario 'A label is shown when the appointment date has passed the target date' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments(
      body: work_order_appointment_response_payload__out_of_target
    )

    visit work_order_path('01551932')

    expect(page).to have_content 'The booked appointment has passed its target date.'
  end

  scenario 'No appointments are booked' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments(
      body: work_order_appointment_response_payload__no_appointments
    )

    visit work_order_path('01551932')

    expect(page).to have_content 'There are no booked appointments.'
  end
end
