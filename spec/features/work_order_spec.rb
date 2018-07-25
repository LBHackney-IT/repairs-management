require 'rails_helper'

RSpec.describe 'Work order' do
  scenario 'search for a work order by reference' do
    WorkOrder.create(ref: '12345678')

    visit '/'
    click_on 'Sign in with Microsoft'
    fill_in 'Work order reference', with: '00000000'
    click_on 'Search'

    expect(page).to have_content 'Could not find a work order with reference 00000000'

    fill_in 'Work order reference', with: '12345678'
    click_on 'Search'

    expect(page).to have_content 'Ref: 12345678'
  end
end
