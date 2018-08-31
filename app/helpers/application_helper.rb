module ApplicationHelper
  def user_signed_in?
    session.key?(:current_user)
  end

  def omniauth_login_link
    if google_auth?
      link_to image_tag('btn_google_signin_light_normal_web.svg', alt: 'Sign in with Google'),
                        '/auth/google_oauth2'
    else
      link_to image_tag('ms_signin_light.svg', alt: 'Sign in with Microsoft'),
                        '/auth/azureactivedirectory'
    end
  end

  def omniauth_logout_url
    if google_auth?
      logout_path
    else
      application_id = ENV['AAD_CLIENT_ID']
      callback_url = url_encode(logout_url)
      "https://login.microsoftonline.com/#{application_id}/oauth2/logout?post_logout_redirect_uri=#{callback_url}"
    end
  end

  def google_auth?
    ENV['GOOGLE_AUTH'] == "true"
  end
end
