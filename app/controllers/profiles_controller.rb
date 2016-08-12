class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: [:get_emails_available]
  before_filter :set_profile, only: [:edit, :update]
  skip_before_filter :verify_authenticity_token, only: [:get_emails_available]

  def get_emails_available
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    set_user
    if @user.nil?
      render nothing: true, status: :unauthorized
    else
      hash = Profile.get_emails_available(profiles_params)
      hash[:status] = {}
      hash[:status][:calls_left] = @user.calls_left
      logger.debug(hash) if Rails.env.development?
      render json: hash.to_json
    end
  end

  def set_primary_email
    profile = current_user.profiles.find(params[:id])
    profile.set_primary_email(params[:main_email])
    render nothing: true, status: :ok
  end

  def edit
  end

  def update
    name = params[:first_name] << ' ' << params[:last_name]
    position = params[:position] << ' at ' << params[:company]
    @profile.update(name: name, position: position)
    @profile.set_primary_email(params[:primary_email])
    redirect_to :back, notice: 'Profile successfully updated.'
  end

  private
  def profiles_params
    params.permit! #(:name, :linkedin_id, :position, :location, :industry, :email)
  end

  def set_user
    if params[:uid].present? and params[:email].present?
      @user = User.find_by(uid: params[:uid], email: params[:email]) || User.create_with_uid_and_email(params[:uid], params[:email])
    else
      nil
    end
  end

  def set_profile
    @profile = current_user.profiles.find(params[:id])
  end

end
