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
    stub_hackney_repairs_work_order_notes

    fill_in 'Work order reference', with: '01551932'
    click_on 'Search'

    expect(page).to have_content 'Work order 01551932'
    expect(page).to have_content 'TEST problem'
    expect(page).to have_content '12 Banister House Homerton High Street E9 6BH'
    expect(page).to have_content 'MR SULEYMAN ERBAS reported on 2:10pm, 29 May 2018'
    expect(page).to have_content 'Telephone number: 02012341234'
    expect(page).to have_content 'Email address: s.erbas@example.com'

    expect(page).to have_content 'Notes'
    within(find('h2', text: 'Notes').find('~ ul')) do
      expect(all('li').map(&:text)).to eq([
        "11:32am, 2 September 2018 by Servitor\nFurther works required; Tiler required to renew splash back and reseal bath",
        "10:12am, 23 August 2018 by MOSHEA\nTenant called to confirm appointment",
      ])
    end
  end
end
