require 'rails_helper'

RSpec.describe 'Authentication' do
  scenario 'prompting to login when not authenticated' do
    visit '/'

    expect(page).to have_current_path('/login')

    click_link 'Login'

    expect(page).to have_current_path('/')
    expect(page).to have_content 'You are logged in as Mike Ross'
    expect(page).to have_link 'Logout', href: %r{login.microsoftonline.com/.*/oauth2/logout\?post_logout_redirect_uri=.*logout}
  end
end
