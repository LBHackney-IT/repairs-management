module ApplicationHelper
  def user_signed_in?
    session.key?(:current_user)
  end

  def azure_active_directory_login_url
    '/auth/azureactivedirectory'
  end

  def azure_active_directory_logout_url
    application_id = ENV['AAD_CLIENT_ID']
    callback_url = url_encode(logout_url)
    "https://login.microsoftonline.com/#{application_id}/oauth2/logout?post_logout_redirect_uri=#{callback_url}"
  end
end
