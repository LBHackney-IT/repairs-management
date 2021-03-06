require 'rails_helper'

RSpec.describe 'Work order' do
  include Helpers::Authentication
  include Helpers::HackneyRepairsRequestStubs

  API_URL = ENV.fetch('HACKNEY_REPAIRS_API_BASE_URL')

  def stub_work_order_tasks(work_order_reference = "01551932")
    stub_request(:get, "#{API_URL}/v1/work_orders/#{work_order_reference}/tasks")
      .to_return(
        status: 200,
        body: [
          {
            "sorCode":                "20060030",
            "sorCodeDescription":     "SOR code description",
            "trade":                  "Trade",
            "workOrderReference":     work_order_reference,
            "repairRequestReference": "00000333",
            "problemDescription":     "Problem description",
            "created":                "2006-06-06T06:06:06",
            "authDate":               "2006-06-06T06:06:07",
            "estimatedCost":          6.66,
            "actualCost":             66.6,
            "completedOn":            "2006-06-06T06:06:08",
            "dateDue":                "2006-06-06T06:06:09",
            "workOrderStatus":        "200",
            "dloStatus":              "1",
            "servitorReference":      "00000999",
            "propertyReference":      "00000111",
            "supplierRef":            "H01",
            "userLogin":              "PUDDING",
            "username":               "Pudding",
            "authorisedBy":           "AUTHORIZER",
            "estimatedUnits":         "6",
            "unitType":               "Itm",
            "taskStatus":             "200",
          }
        ].to_json)
  end

  let(:repairs_history_property_references) { %w(00014665 00024665 00072698 00072699 00072700) }
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
    stub_work_order_tasks

    level = HackneyAPI::RepairsClient::LEVEL_FACILITIES
    stub_hackney_property_by_postcode(reference: 'E9 6BH', min_level: level, max_level: level)

    #
    # stub get_facilities_by_property_reference
    #
    facilities = {
      "results" => [
        {
          "propertyReference" => "00072698",
          "levelCode" => "6",
          "description" => "Facilities",
          "majorReference" => "00074486",
          "address" => "Lift 4031 1-18 Banister House  Homerton High Street",
          "postcode" => "E9 6BH"
        },
        {
          "propertyReference" => "00072699",
          "levelCode" => "6",
          "description" => "Facilities",
          "majorReference" => "00074489",
          "address" => "Lift 4441 109-126 Banister House  Homerton High Street",
          "postcode" => "E9 6BL"
        },
        {
          "propertyReference" => "00072700",
          "levelCode" => "6",
          "description" => "Facilities",
          "majorReference" => "00076278",
          "address" => "Lift 4439 127-144 Banister House  Homerton High Street",
          "postcode" => "E9 6BN"
        }
      ]
    }

    stub_request(:get, "https://hackneyrepairs/v1/properties/00014665/facilities").
      to_return(status: 200, body: facilities.to_json)

    #
    # stub facilities work orders
    #

    stub_hackney_repairs_work_order_block_by_trade(body: [])
    stub_hackney_repairs_work_order_notes
    stub_hackney_repairs_work_order_appointments
    stub_hackney_repairs_work_order_latest_appointments
    stub_hackney_repairs_work_order_reports
    stub_hackney_work_orders_for_property
    stub_cautionary_contact_by_property_reference
    stub_hackney_work_orders_for_property(reference: repairs_history_property_references)
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
    stub_hackney_work_orders_for_property(reference: repairs_history_property_references, body: [
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

    fill_in 'Search by work order reference, postcode or address', with: '01551932'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content "Completed\n31 May 2018, 8:00am-4:15pm"
    expect(page).to have_content 'Priority: N'
    expect(page).to have_content 'Status: In Progress'
    expect(page).to have_content 'Target: 27 Jun 2018, 2:09pm'

    click_on('Repairs history')
    within('#repair-history-tab') do
      choose('Block')

      expect(page).to have_content 'Problem 1'
      expect(page).to have_content 'Problem 2'
      expect(page).to have_link("12345678", href: work_order_path("12345678"))
      expect(page).to have_link("87654321", href: work_order_path("87654321"))
    end

    click_on('Notes')
    expect(find('div[data-note-id="4000"]')).to have_content '2 September 2018, 11:32am by Servitor'
    expect(find('div[data-note-id="4000"]+p')).to have_content 'Further works required; Tiler required to renew splash back and reseal bath'
    expect(find('div[data-note-id="3000"]')).to have_content '23 August 2018, 10:12am by MOSHEA'
    expect(find('div[data-note-id="3000"]+p')).to have_content 'Tenant called to confirm appointment'
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

      within('#repair-history-tab') do
        choose 'Block'

        expect(page).to have_content "Repairs history is showing jobs raised in the last 2 years."

        stub_hackney_work_orders_for_property(years_ago: 5, reference: repairs_history_property_references, body: [
          work_order_response_payload("workOrderReference" => "12345678", "problemDescription" => "Problem 1"),
        ])

        click_on 'Show last 5 years'
        choose 'Block'

        expect(page).to have_content 'Problem 1'
        expect(page).to have_link("12345678", href: work_order_path("12345678"))
        expect(page).to have_content "Repairs history is showing jobs raised in the last 5 years."
        expect(page).not_to have_content "Repairs history is showing jobs raised in the last 2 years."
      end
    end

      scenario "Expect button click to trigger expected behaviour on different hierarchy filter", js: true do
      stub_hackney_work_orders_for_property(reference: repairs_history_property_references,
                                            body: work_orders_by_property_reference_payload + work_orders_by_property_reference_payload__different_property)

      visit work_order_path('01551932')

      within('#repair-history-tab') do
        expect(page).to have_selector 'label', text: 'Estate', count: 1
        expect(page).to have_selector 'label', text: 'Block', count: 1
      end

      choose('hierarchy', option: 'hierarchy-1')

      stub_hackney_work_orders_for_property(years_ago: 5, reference: repairs_history_property_references,
                                            body: work_orders_by_property_reference_payload)

      # FIXME: if capybara's chromium is not headless, the test will crash at
      # the end trying to find favicon.ico, probably because of this line.
      visit "/api/properties/#{property_reference1}/repairs_history?years_ago=5"

      expect(page).to have_content "Loading repairs history"
    end

    scenario "There are no work orders within the last 2 years but there are within the last 5", js: true do
      stub_hackney_work_orders_for_property(reference: repairs_history_property_references, body: [])

      visit work_order_path('01551932')
      choose "Block"
      expect(find('#repair-history-tab')).to have_content 'There are no work orders for this block within the last 2 years.'

      expect(page).to have_selector(:button, 'Show last 5 years')
    end

    scenario "There are no work orders within the last 5 years", js: true do
      stub_hackney_work_orders_for_property(years_ago: 5, reference: repairs_history_property_references, body: [])

      visit work_order_path('01551932')

      within('.load-repairs-history') do
        click_on 'Show last 5 years'
      end

      expect(page).to have_content "There are no work orders within the last 5 years."
    end
  end

  scenario "Entering an unknown work order reference" do
    fill_in 'Search by work order reference, postcode or address', with: ''
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'Please provide a reference, postcode or address'

    stub_hackney_repairs_work_orders(reference: '00000000', status: 404)

    fill_in 'Search by work order reference, postcode or address', with: '00000000'
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

    fill_in 'Search by work order reference, postcode or address', with: '01551932'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_title "01551932 - Hackney Repairs Hub"

    expect(page).to have_content 'Works order: 01551932'
    expect(page).to have_content 'Servitor ref: 10162765'
    expect(page).to have_content 'TEST problem'

    expect(page).to have_content "Homerton High Street 12 Banister House\nE9 6BH"
    expect(page).to have_content "Secure"
    expect(page).to have_content "Lordship South TMO (SN) H2556"

    expect(page).to have_content 'Status: In Progress'
    expect(page).to have_content 'Raised by Celia'
    expect(page).to have_content 'Target: 27 Jun 2018, 2:09pm'
    expect(page).to have_content "Mr Suleyman Erbas"
    expect(page).to have_content "02012 341234"
  end

  scenario 'Search for a work order by postcode', js: true do
    stub_hackney_property_by_postcode(reference: 'E98BH', body: property_by_postcode_response_body__no_properties)

    fill_in 'Search by work order reference, postcode or address', with: 'E98BH'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'We found 0 matching results for E98BH ...'

    stub_hackney_property_by_postcode

    fill_in 'Search by work order reference, postcode or address', with: 'E96BH'
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

    expect(page).to have_title "Homerton High Street 12 Banister House - Hackney Repairs Hub"

    expect(page).to have_content 'Property details'
    expect(page).to have_content 'Homerton High Street 12 Banister House'
    expect(page).to have_content 'Lordship South TMO (SN) H2556'
    expect(page).to have_content 'Contact Alert: Verbal Abuse or Threat of (VA)'
    expect(page).to have_content 'Contact Alert: No Lone Visits (CV)'
    expect(page).to have_content 'Address Alert: Property under Disrepair (DIS)'
    expect(page).to have_content "Caller notes: **Do not attend, bad singing**\nPudding Pudding at 6 Jun 2006, 6:06am"

    expect(page).to have_css(".hackney-tabs-list > li > a", count: 2)

    expect(page.all('.hackney-tabs-list > li > a').map(&:text)).not_to have_content 'Notes'

    within("#repair-history-tab") do
      expect(page).to have_css("h2", text: "Repairs history")
    end
  end

  scenario 'Search for a work order by address', js: true do
    stub_hackney_property_by_address(reference: 'Acacia2', body: property_by_address_response_body__no_properties, limit: 201)

    fill_in 'Search by work order reference, postcode or address', with: 'Acacia2'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'We found 0 matching results for Acacia2 ...'

    stub_hackney_property_by_address(reference: 'Acacia', body: property_by_address_response_body, limit: 201)

    fill_in 'Search by work order reference, postcode or address', with: 'Acacia'
    within('.hackney-search') do
      click_on 'Search'
    end

    expect(page).to have_content 'Acacia'
    expect(page).to have_content '00000017'
    expect(page).to have_content 'We found 28 matching results for Acacia ...'

    within('#hackney-addresses table') do
      expect(page).to have_link("1 Acacia House Lordship Road", href: property_path("00000017"))
      expect(page).to have_link("2 Acacia House Lordship Road", href: property_path("00000018"))
      expect(page).to have_link("3 Acacia House Lordship Road", href: property_path("00000019"))
      expect(page).to have_link("4 Acacia House Lordship Road", href: property_path("00000020"))
      expect(page).to have_link("5 Acacia House Lordship Road", href: property_path("00000021"))
      expect(page).to have_link("6 Acacia House Lordship Road", href: property_path("00000022"))
      expect(page).to have_link("7 Acacia House Lordship Road", href: property_path("00000023"))
      expect(page).to have_link("8 Acacia House Lordship Road", href: property_path("00000024"))
      expect(page).to have_link("9 Acacia House Lordship Road", href: property_path("00000025"))
      expect(page).to have_link("10 Acacia House Lordship Road", href: property_path("00000026"))
      expect(page).to have_link("11 Acacia House Lordship Road", href: property_path("00000027"))
      expect(page).to have_link("12 Acacia House Lordship Road", href: property_path("00000028"))
      expect(page).to have_link("13 Acacia House Lordship Road", href: property_path("00000029"))
      expect(page).to have_link("14 Acacia House Lordship Road", href: property_path("00000030"))
      expect(page).to have_link("15 Acacia House Lordship Road", href: property_path("00000031"))
      expect(page).to have_link("16 Acacia House Lordship Road", href: property_path("00000032"))
      expect(page).to have_link("17 Acacia House Lordship Road", href: property_path("00000033"))
      expect(page).to have_link("18 Acacia House Lordship Road", href: property_path("00000034"))
      expect(page).to have_link("19 Acacia House Lordship Road", href: property_path("00000035"))
      expect(page).to have_link("20 Acacia House Lordship Road", href: property_path("00000036"))
      expect(page).to have_link("21 Acacia House Lordship Road", href: property_path("00000037"))
      expect(page).to have_link("22 Acacia House Lordship Road", href: property_path("00000038"))
      expect(page).to have_link("Psp 5 Acacia House Lordship Road", href: property_path("00050654"))
      expect(page).to have_link("Lift 1449 3-4 & 8-10 & 14-16 & 20-22 Acacia House Lordship Road", href: property_path("00072649"))
      expect(page).to have_link("Lift 1448 1-2 & 5-7 & 11-13 & 17-19 Acacia House Lordship Road", href: property_path("00072650"))
      expect(page).to have_link("1-22 Acacia House Lordship Road", href: property_path("00073953"))
      expect(page).to have_link("1-2 & 5-7 & 11-13 & 17-19 Acacia House Lordship Road", href: property_path("00087477"))
      expect(page).to have_link("3-4 & 8-10 & 14-16 & 20-22 Acacia House Lordship Road", href: property_path("00087478"))
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

    click_on('Notes')
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

    click_on('Notes')
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

  scenario 'Filtering the repairs history by trade related to the property', js: true do
    visit work_order_path('01551932')

    choose 'Block'

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
    stub_hackney_work_orders_for_property(reference: repairs_history_property_references,
                                          body: work_orders_by_property_reference_payload + work_orders_by_property_reference_payload__different_property)

    visit work_order_path('01551932')

    within('#repair-history-tab') do
      expect(page).to have_selector 'label', text: 'Estate', count: 1
      expect(page).to have_selector 'label', text: 'Block', count: 1

      choose('Estate')

      within('table') do
        expect(page).to have_selector 'td', text: 'Plumbing', count: 1
        expect(page).to have_selector 'td', text: 'Electrical', count: 0
      end

      choose('Block')

      within('table') do
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
    expect(page).to have_content "Search by work order reference, postcode or address"
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

  scenario "Show work order tasks", :js do
    visit work_order_path("01551932")

    click_on "Tasks and SORs"

    within("#tasks-tab") do
      expect(page).to have_content("Tasks and SOR codes")

      expect(page).to have_content("SOR")
      expect(page).to have_content("Description")
      expect(page).to have_content("Date added")
      expect(page).to have_content("Quantity (est.)")
      expect(page).to have_content("Cost (est.)")
      expect(page).to have_content("Status")

      expect(page).to have_content("20060030")
      expect(page).to have_content("SOR code description")
      expect(page).to have_content("6 Jun 2006")
      expect(page).to have_content("6 Itm")
      expect(page).to have_content("6.66")
      expect(page).to have_content("Allocated")
    end
  end
end
