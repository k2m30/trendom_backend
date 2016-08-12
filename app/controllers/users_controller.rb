class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:add_profiles, :test] #unless Rails.env.development?
  before_action :set_user
  skip_before_filter :verify_authenticity_token, only: [:download, :add_profiles]

  def index
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

  def cancel_subscription
    @user.cancel_subscription
    redirect_to choose_plan_users_path
  end

  def remove_profile
    profile = Profile.find(params[:id])
    @user.profiles.delete(profile) unless profile.nil?

    redirect_to user_root_path
  end

  def add_profiles
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    # logger.warn params

    if @user.nil?
      render nothing: true, status: :unauthorized
    else
      delta = @user.add_profiles(params)
      hash = {}
      hash[:status] = {}
      hash[:status][:calls_left] = @user.calls_left - delta
      logger.debug(hash.to_json) if Rails.env.development?
      render json: hash.to_json
    end
  end

  def reveal_emails
    current_user.reveal_emails
    render nothing: true, status: :ok
  end

  def progress
    render text: current_user.progress.round(2)
  end

  def download
    respond_to do |format|
      format.csv do
        send_data current_user.export_profiles
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
    end
  end
end
