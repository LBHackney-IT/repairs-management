# We have to manually include a missing dependency for the
# omniauth-azure-activedirectory gem before we can use it.
# https://github.com/AzureAD/omniauth-azure-activedirectory/issues/33
# https://github.com/AzureAD/omniauth-azure-activedirectory/pull/31
require 'net/http'

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do

  if ENV['GOOGLE_AUTH'] == "true"
    creds = Rails.application.credentials.google_auth_unboxed
                 .slice(:client_id, :client_secret)

    opts = {}
    if ENV['HEROKU_APP_NAME'].present?
      pr = ENV['HEROKU_APP_NAME'].split('-').last
      opts[:redirect_uri] = 'https://hackney-repairs-oauth-redirect.herokuapp.com/auth/google_oauth2/callback'
      opts[:state] = pr
    end
    provider :google_oauth2, *creds.values, opts
  end

  provider :azure_activedirectory, ENV['AAD_CLIENT_ID'], ENV['AAD_TENANT']
end
