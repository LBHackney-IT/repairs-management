class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def authenticate_user!
    return if helpers.user_signed_in?
    redirect_to login_path
  end

  def current_user_email
    session[:current_user]["email"]
  end
end
