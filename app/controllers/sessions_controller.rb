class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    logger.info auth_hash
    session[:current_user] = { name: auth_hash.info.name }
    redirect_to root_path
  end

  def destroy
    session.delete(:current_user)
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
