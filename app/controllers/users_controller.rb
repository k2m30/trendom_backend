class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:add]
  skip_before_filter :verify_authenticity_token, only: [:download, :add]
  def show
  end

  def add
    logger.warn params
    set_user

    if @user.nil?
      render nothing: true, status: :unauthorized
    else
      @user.add_profiles(person_params)
      render nothing: true, status: :ok
    end
  end

  def download
    set_user
    respond_to do |format|
      format.html {redirect_to user_path(@user)}
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
    end
  end
end
