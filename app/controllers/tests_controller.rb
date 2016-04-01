class TestsController < ApplicationController
  def get_emails_available
    @email = params[:email]
    @uid = params[:uid]
    @data = params[:data]
    @path = get_emails_available_profiles_path
    render :index
  end

  def add_profiles
    @email = params[:email]
    @uid = params[:uid]
    @data = params[:data]
    @path = add_profiles_user_path(User.first)
    render :index
  end
end
