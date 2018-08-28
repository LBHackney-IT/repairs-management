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
    stub_hackney_work_orders_for_property(reference: property_reference1, body: [
      work_order_response_payload("workOrderReference" => "1234", "problemDescription" => "Problem 1"),
      work_order_response_payload("workOrderReference" => "4321", "problemDescription" => "Problem 2"),
    ])
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    fill_in 'Work order reference', with: '01551932'
    click_on 'Search'

    expect(page).to have_content 'Work order'
    expect(page).to have_content 'UH ref: 01551932'
    expect(page).to have_content 'Servitor ref: 10162765'
    expect(page).to have_content 'TEST problem'

    expect(page).to have_content "12 Banister House Homerton High Street E9 6BH"

    expect(page).to have_content "MR SULEYMAN ERBAS reported on 2:10pm, 29 May 2018"
    expect(page).to have_content '02012341234'
    expect(page).to have_content 's.erbas@example.com'

    expect(page).to have_content "Appointment booked for 8:00am, 30 May 2018 until 12:00pm, 30 May 2018"
    expect(page).to have_content 'Priority: N'
    expect(page).to have_content 'Status: In Progress'
    expect(page).to have_content 'Data source: UH'

    expect(page).to have_content 'Target date: 2:09pm, 27 June 2018'

    expect(page).to have_content 'Notes'
    within(find('h2', text: 'Notes').find('~ ul')) do
      expect(all('li').map(&:text)).to eq([
        "11:32am, 2 September 2018 by Servitor\nFurther works required; Tiler required to renew splash back and reseal bath",
        "10:12am, 23 August 2018 by MOSHEA\nTenant called to confirm appointment",
      ])
    end

    expect(page).to have_content 'Problem 1'
    expect(page).to have_content 'Problem 2'
    expect(page).to have_link("1234", href: work_order_path("1234"))
    expect(page).to have_link("4321", href: work_order_path("4321"))
  end

  scenario 'No notes are returned' do # TODO: remove when the api in sandbox is deployed
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes(
      body: work_order_note_response_payload__no_notes
    )
    stub_hackney_repairs_work_order_appointments
    stub_hackney_work_orders_for_property

    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')
    expect(page).to have_content 'There are no notes for this work order.'
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
    stub_hackney_work_orders_for_property

    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')
    expect(page).to have_content 'There are no notes for this work order.'
  end

  scenario 'A label is shown when the appointment date has passed the target date' do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments(
      body: work_order_appointment_response_payload__out_of_target
    )
    stub_hackney_work_orders_for_property

    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

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
    stub_hackney_work_orders_for_property

    stub_hackney_work_orders_for_property(reference: property_reference1)
    stub_hackney_work_orders_for_property(reference: property_reference2)
    stub_hackney_property_hierarchy(body: property_hierarchy_response)

    visit work_order_path('01551932')

    expect(page).to have_content 'There are no booked appointments.'
  end
end
