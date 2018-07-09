# We have to manually include a missing dependency for the
# omniauth-azure-activedirectory gem before we can use it.
# https://github.com/AzureAD/omniauth-azure-activedirectory/issues/33
# https://github.com/AzureAD/omniauth-azure-activedirectory/pull/31
require 'net/http'

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :azure_activedirectory, ENV['AAD_CLIENT_ID'], ENV['AAD_TENANT']
end
