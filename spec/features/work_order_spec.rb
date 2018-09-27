require 'rails_helper'

RSpec.describe 'Work order' do
  include Helpers::Authentication
  include Helpers::HackneyRepairsRequestStubs

  let(:property_reference1) { '00014665' }
  let(:property_reference2) { '00024665' }
  let(:property_hierarchy_response) do
    [
      {
        propertyReference: property_reference1,
        levelCode: '3',
        description: 'Block',
        majorReference: '00078632',
        address: '37-45 ODD Shrubland Road',
        postCode: 'E8 4NL'
      },
      {
        propertyReference: property_reference2,
        levelCode: '2',
        description: 'Estate',
        majorReference: '00087086',
        address: 'Shrubland Estate  Shrubland Road',
        postCode: 'E8 4NL'
      }
    ]
  end

  before { sign_in }

  scenario 'Search for a work order by reference' do
    fill_in 'Search by work order reference or postcode', with: ''
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'Please provide a reference or postcode'

    stub_hackney_repairs_work_orders(reference: '00000000', status: 404)

    fill_in 'Search by work order reference or postcode', with: '00000000'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'Could not find a work order with reference 00000000'

    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments
    stub_hackney_repairs_work_order_latest_appointments
    stub_hackney_work_orders_for_property(reference: property_reference1, body: [
      work_order_response_payload("workOrderReference" => "1234", "problemDescription" => "Problem 1"),
      work_order_response_payload("workOrderReference" => "4321", "problemDescription" => "Problem 2"),
    ])
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    fill_in 'Search by work order reference or postcode', with: '01551932'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'Works order: 01551932'
    expect(page).to have_content 'Servitor ref: 10162765'
    expect(page).to have_content 'TEST problem'

    expect(page).to have_content "Homerton High Street 12 Banister House E9 6BH"

    expect(page).to have_content "MR SULEYMAN ERBAS 2:10pm, 29 May 2018"
    expect(page).to have_content '02012341234'
    expect(page).to have_content 's.erbas@example.com'

    expect(page).to have_content "Appointment: Completed 8:00am to 4:15pm, 31 May 2018"

    expect(page).to have_content 'Priority: Standard'
    expect(page).to have_content 'Work order: In Progress'
    expect(page).to have_content 'Data source: DRS'

    expect(page).to have_content 'Target date: 27 Jun 2018, 2:09pm'

    expect(page).to have_content 'Notes and appointments'
    within(find('h2', text: 'Notes and appointments').find('~ ul')) do
      expect(all('li').map(&:text)).to eq([
        "2 September 2018, 11:32am by Servitor\nFurther works required; Tiler required to renew splash back and reseal bath",
        "23 August 2018, 10:12am by MOSHEA\nTenant called to confirm appointment",
        "30 May 2018, 8:00am to 12:00pm\nAppointment: Planned Operative name: (PLM) Fatima Bagam TEST Phone number: Priority: standard Created at: 29 May 2018, 2:10pm Data source: DRS",
        "29 May 2018, 2:51pm to 5 June 2018, 2:51pm\nAppointment: Planned Operative name: (PLM) Brian Liverpool Phone number: +447535847993 Priority: standard Created at: 29 May 2018, 2:51pm Data source: DRS",
        "17 October 2017, 9:27am to 24 October 2017, 9:27am\nAppointment: Completed Operative name: (PLM) Fatima Bagam TEST Phone number: Priority: standard Created at: 17 October 2017, 9:27am Data source: DRS"
      ])
    end

    expect(page).to have_content 'Problem 1'
    expect(page).to have_content 'Problem 2'
    expect(page).to have_link("1234", href: work_order_path("1234"))
    expect(page).to have_link("4321", href: work_order_path("4321"))
  end

  scenario 'Search for a work order by postcode' do
    stub_hackney_property_by_postcode(reference: 'E98BH', body: property_by_postcode_response_body__no_properties)

    fill_in 'Search by work order reference or postcode', with: 'E98BH'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'We found 0 matching results for E98BH ...'

    stub_hackney_property_by_postcode

    fill_in 'Search by work order reference or postcode', with: 'E96BH'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'E9 6BH'
    expect(page).to have_content '00014665'
    expect(page).to have_content 'We found 4 matching results for E96BH ...'

    within('#hackney-addresses table') do
      expect(page).to have_selector 'td', text: 'Homerton High Street 10 Banister House'
      expect(page).to have_selector 'td', text: 'Homerton High Street 11 Banister House'
      expect(page).to have_selector 'td', text: 'Homerton High Street 12 Banister House'
      expect(page).to have_selector 'td', text: 'Homerton High Street 13 Banister House'
    end

    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_work_order_appointments
    stub_hackney_repairs_properties
    stub_hackney_work_orders_for_property
    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    click_on 'Homerton High Street 12 Banister House'

    expect(page).to have_content 'Property details'
    expect(page).to have_content 'Homerton High Street 12 Banister House'

    expect(page).to have_css(".hackney-work-order-tab", count: 2)

    expect(page.all('.hackney-work-order-tab').map(&:text)).not_to have_content 'Notes'
  end

  scenario 'No notes or appointments are returned' do # TODO: remove when the api in sandbox is deployed
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes(
      body: work_order_note_response_payload__no_notes
    )
    stub_hackney_repairs_work_order_appointments(
      body: work_order_appointment_response_payload__no_appointments
    )
    stub_hackney_repairs_work_order_latest_appointments(
      body: work_order_appointment_response_payload__no_appointments
    )
    stub_hackney_work_orders_for_property

    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')

    expect(page).to have_content 'There are no notes or appointments for this work order.'
  end

  scenario 'No notes are returned' do # TODO: remove when the api in sandbox is deployed
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes(
      body: work_order_note_response_payload__no_notes
    )
    stub_hackney_repairs_work_order_appointments
    stub_hackney_repairs_work_order_latest_appointments
    stub_hackney_work_orders_for_property

    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')
    expect(page).not_to have_content 'Tenant called to confirm appointment.'
  end

  scenario 'No notes are returned' do # TODO: remove when the api in sandbox is deployed
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes(
      body: {
        "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
        "userMessage" => "We had some problems processing your request"
      },
      status: 500
    )
    stub_hackney_repairs_work_order_appointments
    stub_hackney_repairs_work_order_latest_appointments
    stub_hackney_work_orders_for_property

    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')
    expect(page).not_to have_content 'Tenant called to confirm appointment.'
  end

  scenario 'No appointments are booked' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments(
      body: work_order_appointment_response_payload__no_appointments
    )
    stub_hackney_repairs_work_order_latest_appointments(
      body: work_order_appointment_response_payload__no_appointments
    )
    stub_hackney_work_orders_for_property

    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')

    expect(page).to have_content 'There are no booked appointments.'
  end

  scenario 'No appointments are booked' do # TODO: remove when the api returns [] in this case
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments(
      body: {
        "developerMessage" => "Exception of type 'HackneyRepairs.Actions.MissingAppointmentsException' was thrown.",
        "userMessage" => "Cannot find appointments for the work order reference"
      },
      status: 404
    )
    stub_hackney_repairs_work_order_latest_appointments(
      body: {
        "developerMessage" => "Exception of type 'HackneyRepairs.Actions.MissingAppointmentsException' was thrown.",
        "userMessage" => "Cannot find appointments for the work order reference"
      },
      status: 404
    )
    stub_hackney_work_orders_for_property

    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')

    expect(page).to have_content 'There are no booked appointments.'
  end

  scenario 'Filtering the repairs history by trade related to the property', js: true do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments
    stub_hackney_repairs_work_order_latest_appointments
    stub_hackney_work_orders_for_property
    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')

    within('#repair-history-tab table') do
      expect(page).to have_selector 'td', text: 'Electrical', count: 1
      expect(page).to have_selector 'td', text: 'Domestic gas: servicing', count: 1
      expect(page).to have_selector 'td', text: 'Plumbing', count: 2
    end

    find('label', text: 'Plumbing').click

    within('#repair-history-tab table') do
      expect(page).to have_selector 'td', text: 'Electrical', count: 0
      expect(page).to have_selector 'td', text: 'Domestic gas: servicing', count: 0
      expect(page).to have_selector 'td', text: 'Plumbing', count: 2
    end

    find('label', text: 'Electrical').click

    within('#repair-history-tab table') do
      expect(page).to have_selector 'td', text: 'Electrical', count: 1
      expect(page).to have_selector 'td', text: 'Domestic gas: servicing', count: 0
      expect(page).to have_selector 'td', text: 'Plumbing', count: 2
    end

    find('label', text: 'Electrical').click

    within('#repair-history-tab table') do
      expect(page).to have_selector 'td', text: 'Electrical', count: 0
      expect(page).to have_selector 'td', text: 'Domestic gas: servicing', count: 0
      expect(page).to have_selector 'td', text: 'Plumbing', count: 2
    end

    find('label', text: 'Plumbing').click

    within('#repair-history-tab table') do
      expect(page).to have_selector 'td', text: 'Electrical', count: 1
      expect(page).to have_selector 'td', text: 'Domestic gas: servicing', count: 1
      expect(page).to have_selector 'td', text: 'Plumbing', count: 2
    end
  end

  scenario 'Clicking on search in the navbar to link back to the homepage' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments
    stub_hackney_repairs_work_order_latest_appointments
    stub_hackney_work_orders_for_property
    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')

    within(".hackney-header__right_links") do
      click_on "Search"
    end
    expect(page).to have_content "Search by work order reference or postcode"
  end
end
