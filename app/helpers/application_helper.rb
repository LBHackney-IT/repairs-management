module ApplicationHelper
  # Salt for generating anonymized user ids
  ANONYMIZED_USER_ID_SALT = ENV["ANONYMIZED_USER_ID_SALT"]

  ANONYMIZED_USER_ID_SALT.present? or raise "No ANONYMIZED_USER_ID_SALT supplied."
  10 < ANONYMIZED_USER_ID_SALT.size or raise "ANONYMIZED_USER_ID_SALT must be at least 10 characters long."

  def user_signed_in?
    session.key?(:current_user)
  end

  def omniauth_login_link
    if Rails.env.development?
      button_to '/auth/google_oauth2', class: "button-link" do
        image_tag('btn_google_signin_light_normal_web.svg', alt: 'Sign in with Google')
      end
    else
      button_to '/auth/azureactivedirectory', class: "button-link" do
        image_tag('ms_signin_light.svg', alt: 'Sign in with Microsoft')
      end
    end
  end

  def omniauth_logout_url
    if Rails.env.development?
      logout_path
    else
      application_id = ENV['AAD_CLIENT_ID']
      callback_url = url_encode(logout_url)
      "https://login.microsoftonline.com/#{application_id}/oauth2/logout?post_logout_redirect_uri=#{callback_url}"
    end
  end

  def current_user_email
    session[:current_user]["email"]
  end

  def anonymized_current_user_id
    Digest::SHA256.hexdigest(ANONYMIZED_USER_ID_SALT + current_user_email)
  end
end
