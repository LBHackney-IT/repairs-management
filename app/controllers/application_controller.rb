class ApplicationController < ActionController::Base
  helper_method :user_signed_in?

  def user_signed_in?
    session[:current_user].present?
  end
end
