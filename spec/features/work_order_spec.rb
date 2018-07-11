require 'rails_helper'

RSpec.describe 'Work order' do
  before do
    WorkOrder.create(ref: '12345678')
  end

  scenario 'search for a work order by reference' do
    visit '/'
    click_on 'Sign in with Microsoft'
    fill_in 'Work order reference', with: '00000000'
    click_on 'Search'

    expect(page).to have_content 'Could not find a work order with reference 01234567'

    fill_in 'Work order reference', with: '12345678'
    click_on 'Search'

    expect(page).to have_content 'Details for work order 12345678'
  end
end
