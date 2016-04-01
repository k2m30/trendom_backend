class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:add_profiles] unless Rails.env.development?
  before_action :set_user
  skip_before_filter :verify_authenticity_token, only: [:download, :add_profiles]

  def show
  end

  def add_profiles
    logger.warn params

    if @user.nil?
      render nothing: true, status: :unauthorized
    else
      @user.add_profiles(person_params)
      render nothing: true, status: :ok
    end
  end

  def download
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
      format.csv { send_data @user.export_profiles }
      format.xls { send_data @user.export_profiles(col_sep: "\t") }
    end
  end

  private
  def set_user
    if params[:uid].present? and params[:email].present?
      @user = User.find_by(uid: params[:uid], email: params[:email]) || User.create_with_uid_and_email(uid: params[:uid], email: params[:email])
    else
      @user = current_user
      @user = User.first if Rails.env.development?
    end
  end
end
