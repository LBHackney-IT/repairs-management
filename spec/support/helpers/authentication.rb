module Helpers
  module Authentication
    RSpec.configure do |config|
      config.before :each, type: :feature do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:azureactivedirectory] = OmniAuth::AuthHash.new({
          provider: 'azureactivedirectory',
          info: OmniAuth::AuthHash::InfoHash.new({
            name: 'Mike Ross'
          })
        })
      end

      config.after :each, type: :feature do
        OmniAuth.config.test_mode = false
      end
    end

    def sign_in
      visit '/'
      click_link 'Sign in with Microsoft', wait: 10
    end
  end
end

