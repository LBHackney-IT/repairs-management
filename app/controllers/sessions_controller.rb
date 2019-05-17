class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate_user!, only: [:new, :create, :review_app_login]

  def new
    if helpers.user_signed_in?
      redirect_to root_path
    elsif review_app_login?
      render 'review_app_login'
    else
      render layout: false
    end
  end

  def create
    session[:current_user] = { name: auth_hash.info.name }
    flash[:notice] = ["You have logged in as #{auth_hash.info.name}"]
    redirect_to root_path
  end

  def review_app_login
    if review_app_login? && review_app_compare(params[:username], params[:password])
      session[:current_user] = { name: 'Review User' }
      flash[:notice] = ["You have logged in as Review User"]
      redirect_to root_path
    else
      flash[:notice] = ["Computer says no"]
    end
  end

  def destroy
    session.delete(:current_user)
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  private

  def review_app_login?
    heroku_review_app?
  end

  def review_app_compare(username, password)
    ActiveSupport::SecurityUtils.secure_compare(username, Rails.application.credentials.review_app_login_name) &
      ActiveSupport::SecurityUtils.secure_compare(password, Rails.application.credentials.review_app_login_password)
  end

end
