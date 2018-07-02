class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    session[:current_user] = {
      name: auth_hash.info.name,
      email: auth_hash.info.email
    }

    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
