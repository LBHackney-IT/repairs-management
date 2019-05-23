module Helpers
  module Authentication
    NAME = 'Mike Ross'
    EMAIL = 'pudding@hackney.gov.uk'

    RSpec.configure do |config|
      config.before :each, type: :feature do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:azureactivedirectory] = OmniAuth::AuthHash.new({
          provider: 'azureactivedirectory',
          info: OmniAuth::AuthHash::InfoHash.new({
            name: NAME,
            email: EMAIL
          })
        })
      end

      config.after :each, type: :feature do
        OmniAuth.config.test_mode = false
      end
    end

    def sign_in
      visit '/auth/azureactivedirectory'
    end
  end
end

