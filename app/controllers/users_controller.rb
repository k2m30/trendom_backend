class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:add_profiles] #unless Rails.env.development?
  before_action :set_user
  skip_before_filter :verify_authenticity_token, only: [:download, :add_profiles]

  def show
    @user.active?
  end

  def edit
  end

  def update
    @user.update!(user_params)
    redirect_to choose_plan_users_path
  end

  def choose_plan

  end

  def remove_profile
    profile = Profile.find(params[:id])
    @user.profiles.delete(profile) unless profile.nil?

    redirect_to user_path(@user)
  end

  def add_profiles
    response.headers['Access-Control-Allow-Origin'] = '*'
    logger.warn params

    if @user.nil?
      render nothing: true, status: :unauthorized
    else
      @user.add_profiles(params)
      render nothing: true, status: :ok
    end
  end

  def reveal_emails
    @user.reveal_emails
    render nothing: true, status: :ok
  end

  def progress
    render text: @user.progress.round(2)
  end

  def download
    respond_to do |format|
      format.csv do
        if @user.enough_calls?
          send_data @user.export_profiles
        else
          redirect_to root_path, alert: 'Reduce number of prospects to download according to calls left in your subscription'
        end
      end
    end
  end

  private
  def user_params
    params.require(:user).permit(:card_holder_name, :street_address,
                                 :street_address2, :city, :state, :zip,
                                 :country, :billing_email, :phone)
  end

  def set_user
    if params[:uid].present? and params[:email].present?
      @user = User.find_by(uid: params[:uid], email: params[:email]) || User.create_with_uid_and_email(uid: params[:uid], email: params[:email])
    else
      @user = current_user
      # @user = User.first if Rails.env.development?
    end
  end
end
