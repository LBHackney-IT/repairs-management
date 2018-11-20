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

  before do
    stub_hackney_repairs_work_orders
    stub_hackney_repairs_repair_requests
    stub_hackney_repairs_properties
    stub_hackney_repairs_work_order_block_by_trade(body: [])
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments
    stub_hackney_repairs_work_order_latest_appointments
    stub_hackney_repairs_work_order_reports
    stub_hackney_work_orders_for_property
    stub_hackney_work_orders_for_property(reference: [property_reference1, property_reference2])
    stub_hackney_property_hierarchy(body: property_hierarchy_response)
    stub_hackney_repairs_work_orders_by_reference(
      references: ["11235813"],
      body: [work_order_response_payload("workOrderReference" => "11235813",
                                         "problemDescription" => "A related work order",
                                         "propertyReference" => "00009999")]
    )
    stub_hackney_repairs_properties_by_references(
      references: ["00009999"],
      body: [property_response_payload(property_reference: '00009999', address: 'Taj Mahal')]
    )

    sign_in
  end

  scenario 'Search for a work order by reference (only AJAX content)', js: true do
    stub_hackney_work_orders_for_property(reference: [property_reference1, property_reference2], body: [
      work_order_response_payload("workOrderReference" => "12345678", "problemDescription" => "Problem 1"),
      work_order_response_payload("workOrderReference" => "87654321", "problemDescription" => "Problem 2"),
    ])

    GraphModelImporter.new('test').import_work_order(work_order_ref: "11235813",
                                                     property_ref: property_reference1,
                                                     created: Time.current,
                                                     target_numbers: [])
    GraphModelImporter.new('test').import_note(note_id: 1,
                                               logged_at: Time.current,
                                               work_order_reference: "11235813",
                                               target_numbers: ['01551932'])

    fill_in 'Search by work order reference or postcode', with: '01551932'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content "Completed\n31 May 2018, 8:00am-4:15pm"
    expect(page).to have_content 'Priority: N'
    expect(page).to have_content 'Status: In Progress'
    expect(page).to have_content 'Target: 27 Jun 2018, 2:09pm'

    click_on('Repairs history')
    expect(page).to have_content 'Problem 1'
    expect(page).to have_content 'Problem 2'
    expect(page).to have_link("12345678", href: work_order_path("12345678"))
    expect(page).to have_link("87654321", href: work_order_path("87654321"))

    click_on('Notes and appointments')
    expect(page).to have_content "2 September 2018, 11:32am by Servitor\nFurther works required; Tiler required to renew splash back and reseal bath"
    expect(page).to have_content "23 August 2018, 10:12am by MOSHEA\nTenant called to confirm appointment"
    expect(page).to have_content "30 May 2018, 8:00am-12:00pm\nAppointment: Planned\nOperative name: (PLM) Fatima Bagam TEST\nPhone number:\nCreated: 29 May 2018, 2:10pm\nData source: DRS"
    expect(page).to have_content "29 May 2018, 2:51pm to 5 June 2018, 2:51pm\nAppointment: Planned\nOperative name: (PLM) Brian Liverpool\nPhone number: +447535847993\nCreated: 29 May 2018, 2:51pm\nData source: DRS"
    expect(page).to have_content "17 October 2017, 9:27am to 24 October 2017, 9:27am\nAppointment: Completed\nOperative name: (PLM) Fatima Bagam TEST\nPhone number:\nCreated: 17 October 2017, 9:27am\nData source: DRS"

    click_on('Possibly related')
    expect(page).to have_content "There are no possibly related plumbing work orders from 17 Apr 2018 to 5 Jun 2018."

    click_on('Related repairs')
    expect(page).to have_content 'A related work order'

    click_on('Documents')
    expect(page).to have_link("Works order report", count: 3)
    expect(page).to have_content 'You must be signed into the internal network to view the documents.'

    expect(page).to have_content "Works order report\n20 July 2017, 3:27pm"
    expect(page).to have_content "Works order report\n19 July 2017, 3:23pm"
    expect(page).to have_content "Works order report\n17 July 2017, 9:10pm"

    expect(page).to have_link(href: '\\\\LBHCAPCONINTP01\\portaldata\\HOUSING\\MobileRepairs\\Processed\\Works Order_11380283.pdf')
    expect(page).to have_link(href: '\\\\LBHCAPCONINTP01\\portaldata\\HOUSING\\MobileRepairs\\Unprocessed\\Works Order_11380283 Copy (1).pdf')
    expect(page).to have_link(href: '\\\\LBHCAPCONINTP01\\portaldata\\HOUSING\\MobileRepairs\\Unprocessed\\Works Order_11380283 Copy (2).pdf')
  end

  feature "Loading 5 years repairs history" do
    scenario "Click button to load back 5 years of repairs history", js: true do
      visit work_order_path('01551932')
      expect(page).to have_content "Repairs history is showing jobs raised in the last 2 years."

      stub_hackney_work_orders_for_property(years_ago: 5, reference: [property_reference1, property_reference2], body: [
        work_order_response_payload("workOrderReference" => "12345678", "problemDescription" => "Problem 1"),
      ])

      within('.load-repairs-history') do
        click_on 'Show last 5 years'
      end

      expect(page).to have_content 'Problem 1'
      expect(page).to have_link("12345678", href: work_order_path("12345678"))
      expect(page).to have_content "Repairs history is showing jobs raised in the last 5 years."
      expect(page).not_to have_content "Repairs history is showing jobs raised in the last 2 years."
    end

    scenario "Expect button click to trigger expected behaviour on different hierarchy filter", js: true do
      stub_hackney_work_orders_for_property(reference: [property_reference1, property_reference2],
                                            body: work_orders_by_property_reference_payload + work_orders_by_property_reference_payload__different_property)

      visit work_order_path('01551932')

      within('#repair-history-tab') do
        expect(page).to have_selector 'label', text: 'Estate', count: 1
        expect(page).to have_selector 'label', text: 'Block', count: 1
      end

      choose('hierarchy', option: 'hierarchy-1')

      stub_hackney_work_orders_for_property(years_ago: 5, reference: [property_reference1, property_reference2],
                                            body: work_orders_by_property_reference_payload)

      visit "/api/properties/#{property_reference1}/repairs_history?years_ago=5"

      expect(page).to have_content "Loading repairs history"
    end

    scenario "There are no work orders within the last 2 years but there are within the last 5", js: true do
      stub_hackney_work_orders_for_property(reference: [property_reference1, property_reference2], body: [])

      visit work_order_path('01551932')
      expect(page).to have_content 'There are no work orders within the last 2 years.'

      expect(page).to have_selector(:button, 'Show last 5 years')
    end

    scenario "There are no work orders within the last 5 years", js: true do
      stub_hackney_work_orders_for_property(years_ago: 5, reference: [property_reference1, property_reference2], body: [])

      visit work_order_path('01551932')

      within('.load-repairs-history') do
        click_on 'Show last 5 years'
      end

      expect(page).to have_content "There are no work orders within the last 5 years."
    end
  end

  scenario "Entering an unknown work order reference" do
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
  end

  scenario 'Search for a work order by reference', :db_connection, js: true do
    stub_hackney_work_orders_for_property(reference: property_reference1, body: [
      work_order_response_payload("workOrderReference" => "12345678", "problemDescription" => "Problem 1"),
      work_order_response_payload("workOrderReference" => "87654321", "problemDescription" => "Problem 2"),
    ])

    fill_in 'Search by work order reference or postcode', with: '01551932'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'Works order: 01551932'
    expect(page).to have_content 'Servitor ref: 10162765'
    expect(page).to have_content 'TEST problem'

    expect(page).to have_content "Homerton High Street 12 Banister House\nE9 6BH"

    expect(page).to have_content 'Status: In Progress'
    expect(page).to have_content "Mr Suleyman Erbas"
    expect(page).to have_content "02012341234"
    expect(page).to have_content 'Target: 27 Jun 2018, 2:09pm'
  end

  scenario 'Search for a work order by postcode', js: true do
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

    click_on 'Homerton High Street 12 Banister House'

    expect(page).to have_content 'Property details'
    expect(page).to have_content 'Homerton High Street 12 Banister House'

    expect(page).to have_css(".hackney-work-order-tab", count: 1)

    expect(page.all('.hackney-work-order-tab').map(&:text)).not_to have_content 'Notes and appointments'

    within("#repair-history-tab") do
      expect(page).to have_css("h2", text: "Repairs history")
    end
  end

  scenario 'No notes or appointments are returned', js: true do # TODO: remove when the api in sandbox is deployed
    stub_hackney_repairs_work_order_notes(
      body: work_order_note_response_payload__no_notes
    )
    stub_hackney_repairs_work_order_appointments(
      body: work_order_appointment_response_payload__no_appointments
    )
    stub_hackney_repairs_work_order_latest_appointments(
      body: work_order_appointment_response_payload__no_appointments
    )

    visit work_order_path('01551932')

    click_on('Notes and appointments')
    expect(page).to have_content 'There are no notes or appointments for this work order.'
  end

  scenario 'No notes are returned' do # TODO: remove when the api in sandbox is deployed
    stub_hackney_repairs_work_order_notes(
      body: work_order_note_response_payload__no_notes
    )

    visit work_order_path('01551932')
    expect(page).not_to have_content 'Tenant called to confirm appointment.'
  end

  scenario 'No notes are returned' do # TODO: remove when the api in sandbox is deployed
    stub_hackney_repairs_work_order_notes(
      body: {
        "developerMessage" => "Exception of type 'HackneyRepairs.Actions.RepairsServiceException' was thrown.",
        "userMessage" => "We had some problems processing your request"
      },
      status: 500
    )

    visit work_order_path('01551932')
    expect(page).not_to have_content 'Tenant called to confirm appointment.'
  end

  scenario 'No appointments are booked', js: true do
    stub_hackney_repairs_work_order_appointments(
      body: work_order_appointment_response_payload__no_appointments
    )
    stub_hackney_repairs_work_order_latest_appointments(
      body: work_order_appointment_response_payload__no_appointments
    )

    visit work_order_path('01551932')

    expect(page).to have_content 'There are no booked appointments.'
  end

  scenario 'No appointments are booked', js: true do # TODO: remove when the api returns [] in this case
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

    visit work_order_path('01551932')

    expect(page).to have_content 'There are no booked appointments.'
  end

  scenario 'An appointment does not have a creation date', js: true do # TODO: remove when the api returns [] in this case
    stub_hackney_repairs_work_order_appointments(
      body: work_order_appointments_response_payload__no_creation_date
    )

    visit work_order_path('01551932')

    click_on('Notes and appointments')
    expect(page).to have_content "29 May 2018, 2:51pm to 5 June 2018, 2:51pm\nAppointment: Planned\nOperative name: (PLM) Brian Liverpool\nPhone number: +447535847993\nCreated:\nData source: DRS"
  end

  scenario 'A repair request has info missing' do
    stub_hackney_repairs_repair_requests(
      body: repair_request_response_payload__info_missing
    )

    visit work_order_path('01551932')

    expect(page).to have_content "29 May 2018, 2:10pm"
  end

  scenario 'The property is an estate', js: true do
    stub_hackney_work_orders_for_property(reference: property_reference2, body: work_orders_by_property_reference_payload__different_property)
    stub_hackney_repairs_properties(body: property_response_payload(level_code: 2))
    stub_hackney_repairs_work_order_block_by_trade(status: 403, body: {
      "developerMessage"=>"Exception of type 'HackneyRepairs.Actions.InvalidParameterException' was thrown.",
      "userMessage"=>"403 Forbidden - Invalid parameter provided."
    })

    visit work_order_path('01551932')

    click_on('Possibly related')
    expect(page).to have_content 'Possibly related records relating to an estate are unavailable.'
  end

  scenario 'There are no reports for a work order', js: true do
    stub_hackney_repairs_work_order_reports(body: work_order_reports_response_payload__no_reports)

    visit work_order_path('01551932')

    click_on('Documents')
    expect(page).to have_content "There are no documents for this work order."
  end

  feature "Filtering by trade and hierarchy" do
    scenario 'Filtering the repairs history by trade related to the property', js: true do
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

      find('button', text: 'Clear filters').click

      within('#repair-history-tab table') do
        expect(page).to have_selector 'td', text: 'Electrical', count: 1
        expect(page).to have_selector 'td', text: 'Domestic gas: servicing', count: 1
        expect(page).to have_selector 'td', text: 'Plumbing', count: 2
      end
    end

    scenario 'Filtering the repairs history by the hierarchy of the property', js: true do
      stub_hackney_work_orders_for_property(reference: [property_reference1, property_reference2],
                                            body: work_orders_by_property_reference_payload + work_orders_by_property_reference_payload__different_property)

      visit work_order_path('01551932')

      within('#repair-history-tab') do
        expect(page).to have_selector 'label', text: 'Estate', count: 1
        expect(page).to have_selector 'label', text: 'Block', count: 1
      end

      within('#repair-history-tab table') do
        expect(page).to have_selector 'td', text: 'Plumbing', count: 2
        expect(page).to have_selector 'td', text: 'Electrical', count: 1
      end

      choose('hierarchy', option: 'hierarchy-1')

      within('#repair-history-tab table') do
        expect(page).to have_selector 'td', text: 'Plumbing', count: 1
        expect(page).to have_selector 'td', text: 'Electrical', count: 0
      end

      choose('hierarchy', option: 'hierarchy-0')

      within('#repair-history-tab table') do
        expect(page).to have_selector 'td', text: 'Plumbing', count: 2
        expect(page).to have_selector 'td', text: 'Electrical', count: 1
      end
    end
  end

  scenario 'Clicking on search in the navbar to link back to the homepage' do
    visit work_order_path('01551932')

    within(".hackney-header__right_links") do
      click_on "Search"
    end
    expect(page).to have_content "Search by work order reference or postcode"
  end

  scenario 'Viewing the possibly related tab' do
    stub_hackney_repairs_properties_by_references(
        references: ["00012345"],
        body: [property_response_payload(property_reference: '00012345', address: 'Buckingham  Palace')]
        )
    stub_hackney_repairs_work_order_block_by_trade(
      body: repairs_work_order_block_by_trade_response(trade: 'Plumbing',
                                                       reference: '00012345',
                                                       work_order_reference: '01234567',
                                                       created: '2011-10-09T08:07:06',
                                                       problem_description: 'Something is wrong')
    )

    visit possibly_related_work_orders_api_work_order_path('01551932')

    expect(page).to have_content 'Possibly related'
    cells = all('tbody tr td').map(&:text)
    expect(cells).to eq [
      "01234567",
      "9 Oct 2011\n8:07am",
      "Buckingham\nPalace",
      "Work complete",
      "Plumbing",
      "Something is wrong"
    ]
  end
end
