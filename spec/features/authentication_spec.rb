require 'rails_helper'

RSpec.describe 'Authentication' do
  include Helpers::Authentication

  scenario 'prompting to login when not authenticated' do
    visit '/'

    expect(page).to have_current_path('/login')

    click_link 'Sign in with Microsoft'

    expect(page).to have_current_path('/')
    expect(page).to have_content 'You have logged in as Mike Ross'
    expect(page).to have_link 'Sign out', href: %r{login.microsoftonline.com/.*/oauth2/logout\?post_logout_redirect_uri=.*logout}
  end
end
