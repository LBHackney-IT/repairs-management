class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    if helpers.user_signed_in?
      redirect_to root_path
    else
      render layout: false
    end
  end

  def create
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
